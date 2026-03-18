// @ts-nocheck — Native bridge module, types generated at build time
import { requireNativeModule, EventEmitter } from "expo-modules-core";

type OverlayState = "collapsed" | "recording" | "processing" | "result";

// Use `any` for the native module type — Expo's strict generics
// make it impractical to type the bridge precisely
const NativeOverlay = requireNativeModule("FloatingOverlay");

type OverlayEvents = {
  onBubbleTap: () => void;
  onRecordStop: () => void;
  onRecordCancel: () => void;
  onBubbleLongPress: () => void;
  [key: string]: (...args: any[]) => void;
};

const emitter = new EventEmitter(NativeOverlay as any) as EventEmitter<OverlayEvents>;

// --- Public API ---

export function showBubble(): void {
  NativeOverlay.showBubble();
}

export function hideBubble(): void {
  NativeOverlay.hideBubble();
}

export function destroy(): void {
  NativeOverlay.destroy();
}

export function startRecordingService(): void {
  NativeOverlay.startRecordingService();
}

export function stopRecordingService(): void {
  NativeOverlay.stopRecordingService();
}

export function setOverlayState(state: OverlayState): void {
  NativeOverlay.setOverlayState(state);
}

export function updateMeterLevel(level: number): void {
  NativeOverlay.updateMeterLevel(level);
}

export function setResultText(text: string): void {
  NativeOverlay.setResultText(text);
}

export async function injectText(text: string): Promise<boolean> {
  return NativeOverlay.injectText(text);
}

export function hasOverlayPermission(): boolean {
  return NativeOverlay.hasOverlayPermission();
}

export async function requestOverlayPermission(): Promise<boolean> {
  return NativeOverlay.requestOverlayPermission();
}

export function hasAccessibilityPermission(): boolean {
  return NativeOverlay.hasAccessibilityPermission();
}

export function openAccessibilitySettings(): void {
  NativeOverlay.openAccessibilitySettings();
}

// --- Events ---

export function addBubbleTapListener(listener: () => void) {
  return emitter.addListener("onBubbleTap", listener);
}

export function addRecordStopListener(listener: () => void) {
  return emitter.addListener("onRecordStop", listener);
}

export function addRecordCancelListener(listener: () => void) {
  return emitter.addListener("onRecordCancel", listener);
}

export function addBubbleLongPressListener(listener: () => void) {
  return emitter.addListener("onBubbleLongPress", listener);
}
