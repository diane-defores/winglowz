import { useState, useCallback, useEffect, useRef } from "react";
import {
  ExpoSpeechRecognitionModule,
  useSpeechRecognitionEvent,
} from "expo-speech-recognition";
import {
  useAudioRecorder,
  useAudioRecorderState,
  AudioModule,
  RecordingPresets,
  setAudioModeAsync,
} from "expo-audio";
import * as Clipboard from "expo-clipboard";
import { Alert } from "react-native";
import { useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";
import { transcribeAudio } from "@/lib/whisper";
import { cleanupTranscription } from "@/lib/ai-cleanup";
import { cleanupLocal } from "@/lib/cleanup-local";
import {
  getOpenAIKey,
  getAnthropicKey,
  getPreferredLanguage,
} from "@/lib/storage";
import { RECORDING_MAX_DURATION_MS } from "@/lib/constants";
import { Platform } from "react-native";

// TODO: Replace with Clerk userId when auth is wired up
const TEMP_USER_ID = "local-user";

// Dynamic import — native module only available in dev builds
let FloatingOverlay: typeof import("@/modules/floating-overlay/index") | null =
  null;
try {
  if (Platform.OS === "android") {
    FloatingOverlay = require("@/modules/floating-overlay/index");
  }
} catch {
  // Not available (Expo Go, iOS, web)
}

export type RecordingMode = "free" | "advanced";

export type RecordingState =
  | "idle"
  | "recording"
  | "processing"
  | "enhancing"
  | "done"
  | "error";

export interface VoiceRecordingOptions {
  mode: RecordingMode;
  source?: string;
  autoSave?: boolean;
}

export interface UseVoiceRecordingReturn {
  // State
  state: RecordingState;
  rawText: string;
  cleanedText: string;
  error: string | null;
  meterLevel: number;
  hasApiKeys: boolean;

  // Actions
  startRecording: () => Promise<void>;
  stopRecording: () => Promise<void>;
  cancelRecording: () => void;
  enhanceWithAI: () => Promise<void>;
  copyResult: () => Promise<void>;
  reset: () => void;

  // Mode
  mode: RecordingMode;
  setMode: (mode: RecordingMode) => void;
}

export function useVoiceRecording(
  options: VoiceRecordingOptions = { mode: "free" }
): UseVoiceRecordingReturn {
  const { source = "in-app", autoSave = true } = options;

  // State
  const [mode, setMode] = useState<RecordingMode>(options.mode);
  const [state, setState] = useState<RecordingState>("idle");
  const [rawText, setRawText] = useState("");
  const [cleanedText, setCleanedText] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [meterLevel, setMeterLevel] = useState(0);
  const [hasApiKeys, setHasApiKeys] = useState(false);

  // Refs
  const timeoutRef = useRef<ReturnType<typeof setTimeout>>(undefined);

  // Advanced mode recorder
  const recorder = useAudioRecorder(RecordingPresets.HIGH_QUALITY);
  const recorderState = useAudioRecorderState(recorder, 67); // ~15fps

  // Convex mutation
  const saveTranscription = useMutation(api.transcriptions.save);

  // Check API keys on mount
  useEffect(() => {
    (async () => {
      const key = await getOpenAIKey();
      setHasApiKeys(!!key);
      await AudioModule.requestRecordingPermissionsAsync();
      await setAudioModeAsync({
        playsInSilentMode: true,
        allowsRecording: true,
      });
    })();
  }, []);

  // --- Save to Convex ---
  const saveResult = useCallback(
    async (raw: string, cleaned: string, lang: string, durationMs: number) => {
      if (!autoSave || !raw.trim()) return;
      try {
        await saveTranscription({
          userId: TEMP_USER_ID,
          rawText: raw,
          cleanedText: cleaned,
          language: lang,
          durationMs,
          source,
        });
      } catch (err) {
        console.warn("Failed to save transcription:", err);
      }
    },
    [autoSave, saveTranscription, source]
  );

  // --- FREE MODE: expo-speech-recognition ---
  const recordingStartTime = useRef(0);

  useSpeechRecognitionEvent("result", (event) => {
    const transcript = event.results[0]?.transcript ?? "";
    if (event.isFinal) {
      const cleaned = cleanupLocal(transcript);
      setRawText(transcript);
      setCleanedText(cleaned);
      setState("done");
      const duration = Date.now() - recordingStartTime.current;
      saveResult(transcript, cleaned, "auto", duration);
    } else {
      setRawText(transcript);
      // Simulate meter level from transcript length changes
      setMeterLevel(Math.min(1, Math.random() * 0.6 + 0.2));
    }
  });

  useSpeechRecognitionEvent("error", (event) => {
    setError(`Speech recognition error: ${event.error}`);
    setState("error");
  });

  useSpeechRecognitionEvent("end", () => {
    if (state === "recording") {
      setState(rawText ? "done" : "idle");
    }
  });

  const startFreeRecording = useCallback(async () => {
    setError(null);
    setRawText("");
    setCleanedText("");

    const { granted } =
      await ExpoSpeechRecognitionModule.requestPermissionsAsync();
    if (!granted) {
      Alert.alert("Permission required", "Microphone access is needed.");
      return;
    }

    const lang = await getPreferredLanguage();
    recordingStartTime.current = Date.now();

    ExpoSpeechRecognitionModule.start({
      lang: lang === "auto" ? "fr-FR" : lang,
      interimResults: true,
      requiresOnDeviceRecognition: true,
    });
    setState("recording");
  }, []);

  const stopFreeRecording = useCallback(() => {
    ExpoSpeechRecognitionModule.stop();
  }, []);

  // --- ADVANCED MODE: expo-audio + Whisper API ---

  // Update meter level from recorder state (advanced mode)
  useEffect(() => {
    if (state === "recording" && mode === "advanced" && recorderState.metering != null) {
      const db = recorderState.metering;
      const normalized = Math.max(0, Math.min(1, (db + 60) / 60));
      setMeterLevel(normalized);
    }
  }, [recorderState.metering, state, mode]);

  const processAdvancedRecording = useCallback(
    async (uri: string) => {
      setState("processing");
      try {
        const openaiKey = await getOpenAIKey();
        if (!openaiKey) throw new Error("No OpenAI key");
        const lang = await getPreferredLanguage();

        const result = await transcribeAudio(
          uri,
          openaiKey,
          lang === "auto" ? undefined : lang
        );
        setRawText(result.text);

        const anthropicKey = await getAnthropicKey();
        let cleaned: string;
        if (anthropicKey) {
          cleaned = await cleanupTranscription(result.text, anthropicKey);
        } else {
          cleaned = cleanupLocal(result.text);
        }
        setCleanedText(cleaned);
        setState("done");

        const durationMs = result.duration * 1000;
        saveResult(result.text, cleaned, result.language, durationMs);
      } catch (err) {
        setError(`Transcription failed: ${err}`);
        setState("error");
      }
    },
    [saveResult]
  );

  const startAdvancedRecording = useCallback(async () => {
    setError(null);
    setRawText("");
    setCleanedText("");

    const openaiKey = await getOpenAIKey();
    if (!openaiKey) {
      setError("OpenAI API key required for Advanced mode. Go to Settings.");
      setState("error");
      return;
    }

    try {
      await recorder.prepareToRecordAsync();
      recorder.record();
      recordingStartTime.current = Date.now();
      setState("recording");

      timeoutRef.current = setTimeout(async () => {
        if (recorder.isRecording) {
          await recorder.stop();
          if (recorder.uri) processAdvancedRecording(recorder.uri);
        }
      }, RECORDING_MAX_DURATION_MS);
    } catch (err) {
      setError(`Recording failed: ${err}`);
      setState("error");
    }
  }, [recorder, processAdvancedRecording]);

  const stopAdvancedRecording = useCallback(async () => {
    if (timeoutRef.current) clearTimeout(timeoutRef.current);
    try {
      await recorder.stop();
      if (recorder.uri) {
        processAdvancedRecording(recorder.uri);
      }
    } catch (err) {
      setError(`Recording failed: ${err}`);
      setState("error");
    }
  }, [recorder, processAdvancedRecording]);

  // --- PUBLIC API ---

  const startRecording = useCallback(async () => {
    // Start foreground service to keep recording alive when screen is off
    try {
      FloatingOverlay?.startRecordingService();
    } catch {
      // Native module not available — recording will stop if screen turns off
    }

    if (mode === "free") {
      await startFreeRecording();
    } else {
      await startAdvancedRecording();
    }
  }, [mode, startFreeRecording, startAdvancedRecording]);

  const stopRecording = useCallback(async () => {
    if (mode === "free") {
      stopFreeRecording();
    } else {
      await stopAdvancedRecording();
    }

    // Stop foreground service after recording ends
    try {
      FloatingOverlay?.stopRecordingService();
    } catch {
      // Native module not available
    }
  }, [mode, stopFreeRecording, stopAdvancedRecording]);

  const cancelRecording = useCallback(() => {
    if (timeoutRef.current) clearTimeout(timeoutRef.current);

    if (mode === "free") {
      ExpoSpeechRecognitionModule.stop();
    } else if (recorder.isRecording) {
      recorder.stop();
    }

    // Stop foreground service
    try {
      FloatingOverlay?.stopRecordingService();
    } catch {
      // Native module not available
    }

    setRawText("");
    setCleanedText("");
    setError(null);
    setState("idle");
  }, [mode, recorder]);

  const enhanceWithAI = useCallback(async () => {
    if (!rawText) return;

    const anthropicKey = await getAnthropicKey();
    if (!anthropicKey) {
      Alert.alert(
        "API Key Required",
        "Set your Anthropic key in Settings to use AI enhancement."
      );
      return;
    }

    setState("enhancing");
    try {
      const cleaned = await cleanupTranscription(rawText, anthropicKey);
      setCleanedText(cleaned);
      setState("done");

      // Update saved transcription with enhanced text
      const duration = Date.now() - recordingStartTime.current;
      saveResult(rawText, cleaned, "auto", duration);
    } catch (err) {
      setError(`Enhancement failed: ${err}`);
      setState("error");
    }
  }, [rawText, saveResult]);

  const copyResult = useCallback(async () => {
    const text = cleanedText || rawText;
    if (!text) return;
    await Clipboard.setStringAsync(text);
  }, [cleanedText, rawText]);

  const reset = useCallback(() => {
    setRawText("");
    setCleanedText("");
    setError(null);
    setState("idle");
    setMeterLevel(0);
  }, []);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (timeoutRef.current) clearTimeout(timeoutRef.current);
    };
  }, []);

  return {
    state,
    rawText,
    cleanedText,
    error,
    meterLevel,
    hasApiKeys,
    startRecording,
    stopRecording,
    cancelRecording,
    enhanceWithAI,
    copyResult,
    reset,
    mode,
    setMode,
  };
}
