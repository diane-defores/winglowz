import { useState, useCallback, useEffect, useRef } from "react";
import { Platform, AppState } from "react-native";
import { logInfo, logWarn, logError } from "@/lib/debug-log";

// Dynamic import — module only available after native build
let FloatingOverlay: typeof import("@/modules/floating-overlay/index") | null =
  null;

try {
  if (Platform.OS === "android") {
    FloatingOverlay = require("@/modules/floating-overlay/index");
    logInfo("Native overlay module loaded");
  }
} catch (e) {
  logWarn(`Native overlay module not available: ${e}`);
}

export interface OverlayPermissions {
  isAvailable: boolean;
  hasOverlayPermission: boolean;
  hasAccessibilityPermission: boolean;
  overlayEnabled: boolean;

  requestOverlayPermission: () => Promise<boolean>;
  openAccessibilitySettings: () => void;
  showBubble: () => void;
  hideBubble: () => void;
  refreshPermissions: () => void;
}

export function useOverlayPermissions(): OverlayPermissions {
  const isAvailable = Platform.OS === "android" && FloatingOverlay != null;
  const [hasOverlayPermission, setHasOverlayPermission] = useState(false);
  const [hasAccessibilityPermission, setHasAccessibilityPermission] =
    useState(false);
  const [overlayEnabled, setOverlayEnabled] = useState(false);
  const appStateRef = useRef(AppState.currentState);

  const refreshPermissions = useCallback(() => {
    if (!isAvailable || !FloatingOverlay) {
      logInfo(`refreshPermissions: isAvailable=${isAvailable}, module=${!!FloatingOverlay}`);
      return;
    }
    const overlay = FloatingOverlay.hasOverlayPermission();
    const a11y = FloatingOverlay.hasAccessibilityPermission();
    logInfo(`Permissions: overlay=${overlay}, accessibility=${a11y}`);
    setHasOverlayPermission(overlay);
    setHasAccessibilityPermission(a11y);
  }, [isAvailable]);

  // Refresh on mount
  useEffect(() => {
    refreshPermissions();
  }, [refreshPermissions]);

  // Refresh when app returns from background (user was in Android settings)
  useEffect(() => {
    const sub = AppState.addEventListener("change", (nextState) => {
      if (
        appStateRef.current.match(/inactive|background/) &&
        nextState === "active"
      ) {
        logInfo("App returned to foreground — refreshing permissions");
        refreshPermissions();
      }
      appStateRef.current = nextState;
    });
    return () => sub.remove();
  }, [refreshPermissions]);

  const requestOverlayPermission = useCallback(async (): Promise<boolean> => {
    if (!FloatingOverlay) {
      logError("requestOverlayPermission: module not available");
      return false;
    }
    logInfo("Opening Android overlay permission settings...");
    const granted = await FloatingOverlay.requestOverlayPermission();
    logInfo(`Overlay permission result: ${granted}`);
    setHasOverlayPermission(granted);
    return granted;
  }, []);

  const openAccessibilitySettings = useCallback(() => {
    if (!FloatingOverlay) return;
    logInfo("Opening accessibility settings...");
    FloatingOverlay.openAccessibilitySettings();
  }, []);

  const showBubble = useCallback(() => {
    if (!FloatingOverlay) {
      logError("showBubble: module not available");
      return;
    }
    // Re-check permission right before showing
    const hasPerm = FloatingOverlay.hasOverlayPermission();
    logInfo(`showBubble: permission=${hasPerm}, SDK=${Platform.Version}`);
    if (!hasPerm) {
      logWarn("showBubble: permission not granted, aborting");
      setHasOverlayPermission(false);
      return;
    }
    try {
      FloatingOverlay.showBubble();
      logInfo("showBubble: service start requested");
      setOverlayEnabled(true);
    } catch (e) {
      logError(`showBubble failed: ${e}`);
    }
  }, []);

  const hideBubble = useCallback(() => {
    if (!FloatingOverlay) return;
    logInfo("hideBubble called");
    FloatingOverlay.hideBubble();
    setOverlayEnabled(false);
  }, []);

  return {
    isAvailable,
    hasOverlayPermission,
    hasAccessibilityPermission,
    overlayEnabled,
    requestOverlayPermission,
    openAccessibilitySettings,
    showBubble,
    hideBubble,
    refreshPermissions,
  };
}
