// In-app debug logger — viewable in Settings, copyable to clipboard
// No adb needed.

type LogEntry = {
  time: string;
  level: "INFO" | "WARN" | "ERROR";
  message: string;
};

const MAX_ENTRIES = 50;
const entries: LogEntry[] = [];
let listeners: Array<() => void> = [];

function now(): string {
  const d = new Date();
  return `${d.getHours().toString().padStart(2, "0")}:${d.getMinutes().toString().padStart(2, "0")}:${d.getSeconds().toString().padStart(2, "0")}`;
}

export function logInfo(message: string) {
  entries.push({ time: now(), level: "INFO", message });
  if (entries.length > MAX_ENTRIES) entries.shift();
  listeners.forEach((fn) => fn());
}

export function logWarn(message: string) {
  entries.push({ time: now(), level: "WARN", message });
  if (entries.length > MAX_ENTRIES) entries.shift();
  listeners.forEach((fn) => fn());
}

export function logError(message: string) {
  entries.push({ time: now(), level: "ERROR", message });
  if (entries.length > MAX_ENTRIES) entries.shift();
  listeners.forEach((fn) => fn());
}

export function getLogEntries(): LogEntry[] {
  return [...entries];
}

export function getLogText(): string {
  return entries
    .map((e) => `[${e.time}] ${e.level}: ${e.message}`)
    .join("\n");
}

export function clearLogs() {
  entries.length = 0;
  listeners.forEach((fn) => fn());
}

export function onLogChange(fn: () => void): () => void {
  listeners.push(fn);
  return () => {
    listeners = listeners.filter((l) => l !== fn);
  };
}
