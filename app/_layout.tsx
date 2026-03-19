import { Stack } from "expo-router";
import { StatusBar } from "expo-status-bar";
import { ConvexProvider, ConvexReactClient } from "convex/react";
import { OverlayFAB } from "@/components/OverlayFAB";
import { OverlayBridge } from "@/components/OverlayBridge";
import { useOverlayPermissions } from "@/hooks/useOverlayPermissions";

// TODO: Replace with your Convex URL from `npx convex dev`
const convex = new ConvexReactClient(
  process.env.EXPO_PUBLIC_CONVEX_URL ?? "https://placeholder.convex.cloud"
);

function AppContent() {
  const overlay = useOverlayPermissions();

  // Hide in-app FAB when system overlay is active (avoid duplicate buttons)
  const showInAppFab = !overlay.overlayEnabled;

  return (
    <>
      <StatusBar style="light" />
      <Stack
        screenOptions={{
          headerShown: false,
          contentStyle: { backgroundColor: "#0f172a" },
        }}
      />
      <OverlayFAB visible={showInAppFab} />
      <OverlayBridge />
    </>
  );
}

export default function RootLayout() {
  return (
    <ConvexProvider client={convex}>
      <AppContent />
    </ConvexProvider>
  );
}
