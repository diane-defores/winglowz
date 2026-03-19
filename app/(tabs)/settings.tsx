import { useState, useEffect, useCallback } from "react";
import {
  View,
  Text,
  TextInput,
  Pressable,
  ScrollView,
  StyleSheet,
  Alert,
  Platform,
} from "react-native";
import * as Clipboard from "expo-clipboard";
import { SafeAreaView } from "react-native-safe-area-context";
import { Colors, APP_NAME } from "@/lib/constants";
import { getLogText, clearLogs, onLogChange } from "@/lib/debug-log";
import { useOverlayPermissions } from "@/hooks/useOverlayPermissions";
import {
  getOpenAIKey,
  setOpenAIKey,
  getAnthropicKey,
  setAnthropicKey,
  getPreferredLanguage,
  setPreferredLanguage,
} from "@/lib/storage";

const colors = Colors.dark;

const LANGUAGES = [
  { code: "auto", label: "Auto-detect" },
  { code: "fr", label: "Fran\u00e7ais" },
  { code: "en", label: "English" },
  { code: "es", label: "Espa\u00f1ol" },
  { code: "de", label: "Deutsch" },
  { code: "pt", label: "Portugu\u00eas" },
  { code: "it", label: "Italiano" },
  { code: "nl", label: "Nederlands" },
  { code: "ja", label: "Japanese" },
  { code: "zh", label: "Chinese" },
];

export default function SettingsScreen() {
  const [openaiKey, setOpenaiKeyState] = useState("");
  const [anthropicKey, setAnthropicKeyState] = useState("");
  const [language, setLanguage] = useState("auto");
  const [saved, setSaved] = useState(false);

  const overlay = useOverlayPermissions();
  const [logText, setLogText] = useState("");
  const [showLogs, setShowLogs] = useState(false);

  // Subscribe to log changes
  useEffect(() => {
    const unsub = onLogChange(() => setLogText(getLogText()));
    setLogText(getLogText()); // initial load
    return unsub;
  }, []);

  useEffect(() => {
    (async () => {
      const oai = await getOpenAIKey();
      const ant = await getAnthropicKey();
      const lang = await getPreferredLanguage();
      if (oai) setOpenaiKeyState(oai);
      if (ant) setAnthropicKeyState(ant);
      setLanguage(lang);
    })();
  }, []);

  const handleSave = useCallback(async () => {
    if (!openaiKey.trim()) {
      Alert.alert("Required", "OpenAI API key is required for transcription.");
      return;
    }
    await setOpenAIKey(openaiKey.trim());
    if (anthropicKey.trim()) {
      await setAnthropicKey(anthropicKey.trim());
    }
    await setPreferredLanguage(language);
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  }, [openaiKey, anthropicKey, language]);

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.title}>Settings</Text>

        {/* OpenAI Key */}
        <View style={styles.section}>
          <Text style={styles.label}>OpenAI API Key *</Text>
          <Text style={styles.hint}>
            Required for Whisper transcription (~$0.006/min)
          </Text>
          <TextInput
            style={styles.input}
            value={openaiKey}
            onChangeText={setOpenaiKeyState}
            placeholder="sk-..."
            placeholderTextColor={colors.textMuted}
            secureTextEntry
            autoCapitalize="none"
            autoCorrect={false}
          />
        </View>

        {/* Anthropic Key */}
        <View style={styles.section}>
          <Text style={styles.label}>Anthropic API Key</Text>
          <Text style={styles.hint}>
            Optional. Enables AI text cleanup with Claude Haiku (~$0.001/req)
          </Text>
          <TextInput
            style={styles.input}
            value={anthropicKey}
            onChangeText={setAnthropicKeyState}
            placeholder="sk-ant-..."
            placeholderTextColor={colors.textMuted}
            secureTextEntry
            autoCapitalize="none"
            autoCorrect={false}
          />
        </View>

        {/* Floating Button — Guided Setup */}
        <View style={styles.section}>
          <Text style={styles.label}>Floating Voice Button</Text>
          <Text style={styles.hint}>
            Dictate text anywhere on your phone — even in other apps.
            A small microphone button floats on your screen.
          </Text>

          {overlay.isAvailable ? (
            <View style={{ gap: 10 }}>
              {/* Step 1: Overlay permission */}
              <View style={styles.stepCard}>
                <View style={styles.stepHeader}>
                  <Text style={styles.stepNumber}>
                    {overlay.hasOverlayPermission ? "✓" : "1"}
                  </Text>
                  <View style={{ flex: 1 }}>
                    <Text style={styles.stepTitle}>
                      Display over other apps
                    </Text>
                    <Text style={styles.stepHint}>
                      {overlay.hasOverlayPermission
                        ? "Permission granted"
                        : "Android needs your permission to show the floating button over other apps."}
                    </Text>
                  </View>
                </View>
                {!overlay.hasOverlayPermission && (
                  <Pressable
                    onPress={overlay.requestOverlayPermission}
                    style={styles.stepBtn}
                  >
                    <Text style={styles.stepBtnText}>
                      Open Android Settings
                    </Text>
                  </Pressable>
                )}
              </View>

              {/* Step 2: Activate overlay */}
              <View
                style={[
                  styles.stepCard,
                  !overlay.hasOverlayPermission && styles.stepCardDisabled,
                ]}
              >
                <View style={styles.stepHeader}>
                  <Text style={styles.stepNumber}>
                    {overlay.overlayEnabled ? "✓" : "2"}
                  </Text>
                  <View style={{ flex: 1 }}>
                    <Text style={styles.stepTitle}>
                      Start floating button
                    </Text>
                    <Text style={styles.stepHint}>
                      {overlay.overlayEnabled
                        ? "The button is active! Switch to another app to see it."
                        : "A small microphone button will appear on your screen. You can drag it anywhere."}
                    </Text>
                  </View>
                </View>
                {overlay.hasOverlayPermission && (
                  <Pressable
                    onPress={
                      overlay.overlayEnabled
                        ? overlay.hideBubble
                        : overlay.showBubble
                    }
                    style={[
                      styles.stepBtn,
                      overlay.overlayEnabled && styles.stepBtnDanger,
                    ]}
                  >
                    <Text
                      style={[
                        styles.stepBtnText,
                        overlay.overlayEnabled && styles.stepBtnTextDanger,
                      ]}
                    >
                      {overlay.overlayEnabled
                        ? "Hide Floating Button"
                        : "Show Floating Button"}
                    </Text>
                  </Pressable>
                )}
              </View>

              {/* Step 3: Text injection (optional) */}
              <View
                style={[
                  styles.stepCard,
                  !overlay.hasOverlayPermission && styles.stepCardDisabled,
                ]}
              >
                <View style={styles.stepHeader}>
                  <Text style={styles.stepNumber}>
                    {overlay.hasAccessibilityPermission ? "✓" : "3"}
                  </Text>
                  <View style={{ flex: 1 }}>
                    <Text style={styles.stepTitle}>
                      Auto-paste text (optional)
                    </Text>
                    <Text style={styles.stepHint}>
                      {overlay.hasAccessibilityPermission
                        ? "Text will be injected directly into the active text field."
                        : "Without this, text is copied to clipboard and you paste manually. Enable the VoiceFlowz accessibility service to auto-paste."}
                    </Text>
                  </View>
                </View>
                {overlay.hasOverlayPermission &&
                  !overlay.hasAccessibilityPermission && (
                    <Pressable
                      onPress={overlay.openAccessibilitySettings}
                      style={styles.stepBtn}
                    >
                      <Text style={styles.stepBtnText}>
                        Open Accessibility Settings
                      </Text>
                    </Pressable>
                  )}
              </View>

              {/* How to use */}
              {overlay.overlayEnabled && (
                <View style={styles.howToUse}>
                  <Text style={styles.howToUseTitle}>How to use</Text>
                  <Text style={styles.howToUseText}>
                    1. Open any app (WhatsApp, Chrome, Gmail...){"\n"}
                    2. Tap the floating microphone button{"\n"}
                    3. Speak — you'll see the waveform{"\n"}
                    4. Tap the checkmark when done{"\n"}
                    5. Text is copied to clipboard (or auto-pasted)
                  </Text>
                </View>
              )}
            </View>
          ) : (
            <View style={styles.stepCard}>
              <Text style={styles.stepHint}>
                System overlay is only available on Android.
                The in-app floating button is active on all platforms.
              </Text>
            </View>
          )}
        </View>

        {/* Language */}
        <View style={styles.section}>
          <Text style={styles.label}>Transcription Language</Text>
          <View style={styles.languageGrid}>
            {LANGUAGES.map((lang) => (
              <Pressable
                key={lang.code}
                onPress={() => setLanguage(lang.code)}
                style={[
                  styles.languageBtn,
                  language === lang.code && styles.languageBtnActive,
                ]}
              >
                <Text
                  style={[
                    styles.languageBtnText,
                    language === lang.code && styles.languageBtnTextActive,
                  ]}
                >
                  {lang.label}
                </Text>
              </Pressable>
            ))}
          </View>
        </View>

        {/* Save */}
        <Pressable onPress={handleSave} style={styles.saveBtn}>
          <Text style={styles.saveBtnText}>
            {saved ? "Saved!" : "Save Settings"}
          </Text>
        </Pressable>

        {/* Debug Logs */}
        <View style={styles.section}>
          <Pressable
            onPress={() => setShowLogs(!showLogs)}
            style={styles.debugToggle}
          >
            <Text style={styles.label}>
              {showLogs ? "Hide Debug Logs" : "Show Debug Logs"}
            </Text>
            <Text style={styles.hint}>
              Android {Platform.Version} — Tap to {showLogs ? "hide" : "see"} what's happening
            </Text>
          </Pressable>

          {showLogs && (
            <View style={{ gap: 8, marginTop: 8 }}>
              <View style={styles.logBox}>
                <Text style={styles.logText}>
                  {logText || "No logs yet. Try enabling the overlay."}
                </Text>
              </View>
              <View style={{ flexDirection: "row", gap: 8 }}>
                <Pressable
                  onPress={async () => {
                    await Clipboard.setStringAsync(
                      `VoiceFlowz Debug — Android ${Platform.Version}\n\n${logText}`
                    );
                    Alert.alert("Copied!", "Logs copied to clipboard.");
                  }}
                  style={[styles.stepBtn, { flex: 1 }]}
                >
                  <Text style={styles.stepBtnText}>Copy Logs</Text>
                </Pressable>
                <Pressable
                  onPress={() => {
                    clearLogs();
                    setLogText("");
                  }}
                  style={[styles.stepBtn, styles.stepBtnDanger, { flex: 1 }]}
                >
                  <Text style={styles.stepBtnTextDanger}>Clear</Text>
                </Pressable>
              </View>
            </View>
          )}
        </View>

        {/* About */}
        <View style={styles.about}>
          <Text style={styles.aboutText}>
            {APP_NAME} v1.0.0{"\n"}
            Voice typing & clipboard sync{"\n"}
            Part of the WinFlowz ecosystem
          </Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  content: {
    paddingHorizontal: 24,
    paddingTop: 16,
    paddingBottom: 40,
  },
  title: {
    fontSize: 28,
    fontWeight: "700",
    color: colors.text,
    marginBottom: 24,
  },
  section: {
    marginBottom: 24,
  },
  label: {
    color: colors.text,
    fontSize: 16,
    fontWeight: "600",
    marginBottom: 4,
  },
  hint: {
    color: colors.textMuted,
    fontSize: 12,
    marginBottom: 8,
  },
  input: {
    backgroundColor: colors.surface,
    borderRadius: 10,
    padding: 14,
    color: colors.text,
    fontSize: 15,
    borderWidth: 1,
    borderColor: colors.border,
  },
  languageGrid: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 8,
  },
  languageBtn: {
    backgroundColor: colors.surface,
    borderRadius: 8,
    paddingHorizontal: 14,
    paddingVertical: 8,
    borderWidth: 1,
    borderColor: colors.border,
  },
  languageBtnActive: {
    backgroundColor: colors.primary,
    borderColor: colors.primary,
  },
  languageBtnText: {
    color: colors.textSecondary,
    fontSize: 13,
  },
  languageBtnTextActive: {
    color: "#fff",
    fontWeight: "600",
  },
  stepCard: {
    backgroundColor: colors.surface,
    borderRadius: 12,
    padding: 14,
    borderWidth: 1,
    borderColor: colors.border,
  },
  stepCardDisabled: {
    opacity: 0.4,
  },
  stepHeader: {
    flexDirection: "row",
    gap: 12,
    alignItems: "flex-start",
  },
  stepNumber: {
    width: 28,
    height: 28,
    borderRadius: 14,
    backgroundColor: colors.primary + "20",
    color: colors.primaryLight,
    fontSize: 14,
    fontWeight: "700",
    textAlign: "center",
    lineHeight: 28,
    overflow: "hidden",
  },
  stepTitle: {
    color: colors.text,
    fontSize: 14,
    fontWeight: "600",
    marginBottom: 2,
  },
  stepHint: {
    color: colors.textMuted,
    fontSize: 12,
    lineHeight: 17,
  },
  stepBtn: {
    marginTop: 10,
    backgroundColor: colors.primary,
    borderRadius: 8,
    paddingVertical: 10,
    alignItems: "center",
  },
  stepBtnText: {
    color: "#fff",
    fontSize: 13,
    fontWeight: "600",
  },
  stepBtnDanger: {
    backgroundColor: colors.danger + "18",
  },
  stepBtnTextDanger: {
    color: colors.danger,
  },
  howToUse: {
    backgroundColor: colors.primary + "10",
    borderRadius: 12,
    padding: 14,
    borderWidth: 1,
    borderColor: colors.primary + "30",
  },
  howToUseTitle: {
    color: colors.primaryLight,
    fontSize: 14,
    fontWeight: "600",
    marginBottom: 6,
  },
  howToUseText: {
    color: colors.textSecondary,
    fontSize: 13,
    lineHeight: 20,
  },
  saveBtn: {
    backgroundColor: colors.primary,
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: "center",
    marginTop: 8,
  },
  saveBtnText: {
    color: "#fff",
    fontSize: 16,
    fontWeight: "700",
  },
  debugToggle: {
    paddingVertical: 4,
  },
  logBox: {
    backgroundColor: "#0a0f1a",
    borderRadius: 8,
    padding: 12,
    maxHeight: 300,
    borderWidth: 1,
    borderColor: colors.border,
  },
  logText: {
    color: "#a3e635",
    fontSize: 11,
    fontFamily: Platform.OS === "ios" ? "Menlo" : "monospace",
    lineHeight: 16,
  },
  about: {
    marginTop: 32,
    alignItems: "center",
  },
  aboutText: {
    color: colors.textMuted,
    fontSize: 12,
    textAlign: "center",
    lineHeight: 18,
  },
});
