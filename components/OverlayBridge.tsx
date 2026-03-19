// Bridges native overlay events to the JS recording hook.
// When user taps the system overlay button, this starts/stops recording
// and sends results back to the native overlay for display.

import { useEffect } from "react";
import { Platform } from "react-native";
import { useVoiceRecording } from "@/hooks/useVoiceRecording";
import { logInfo, logError } from "@/lib/debug-log";

let FloatingOverlay: typeof import("@/modules/floating-overlay/index") | null =
  null;
try {
  if (Platform.OS === "android") {
    FloatingOverlay = require("@/modules/floating-overlay/index");
  }
} catch {
  // Not available
}

export function OverlayBridge() {
  const {
    state,
    cleanedText,
    rawText,
    meterLevel,
    startRecording,
    stopRecording,
    cancelRecording,
    copyResult,
  } = useVoiceRecording({ mode: "free", source: "overlay" });

  // Listen to native overlay events
  useEffect(() => {
    if (!FloatingOverlay) return;

    const tapSub = FloatingOverlay.addBubbleTapListener(() => {
      logInfo("Overlay: bubble tapped — starting recording");
      FloatingOverlay?.setOverlayState("recording");
      startRecording();
    });

    const stopSub = FloatingOverlay.addRecordStopListener(() => {
      logInfo("Overlay: done tapped — stopping recording");
      stopRecording();
    });

    const cancelSub = FloatingOverlay.addRecordCancelListener(() => {
      logInfo("Overlay: cancel tapped");
      FloatingOverlay?.setOverlayState("collapsed");
      cancelRecording();
    });

    const longPressSub = FloatingOverlay.addBubbleLongPressListener(() => {
      logInfo("Overlay: long press — no action yet");
    });

    return () => {
      tapSub.remove();
      stopSub.remove();
      cancelSub.remove();
      longPressSub.remove();
    };
  }, [startRecording, stopRecording, cancelRecording]);

  // Push recording state changes to native overlay
  useEffect(() => {
    if (!FloatingOverlay) return;

    if (state === "recording") {
      FloatingOverlay.setOverlayState("recording");
    } else if (state === "processing") {
      FloatingOverlay.setOverlayState("processing");
    } else if (state === "done") {
      const text = cleanedText || rawText;
      if (text) {
        logInfo(`Overlay: transcription done (${text.length} chars)`);
        FloatingOverlay.setOverlayState("result");
        // Copy to clipboard + try to inject
        copyResult();
        FloatingOverlay.injectText(text).then((injected) => {
          logInfo(`Overlay: text ${injected ? "injected" : "copied to clipboard"}`);
        }).catch((e) => {
          logError(`Overlay: inject failed: ${e}`);
        });
      } else {
        FloatingOverlay.setOverlayState("collapsed");
      }
    } else if (state === "error") {
      logError("Overlay: recording error, collapsing");
      FloatingOverlay.setOverlayState("collapsed");
    }
  }, [state, cleanedText, rawText, copyResult]);

  // Push meter level to native waveform
  useEffect(() => {
    if (!FloatingOverlay || state !== "recording") return;
    FloatingOverlay.updateMeterLevel(meterLevel);
  }, [meterLevel, state]);

  // This component renders nothing — it's purely a bridge
  return null;
}
