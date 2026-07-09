module.exports = {
  apps: [{
    name: "winglowz_app",
    cwd: "/home/claude/winglowz/winglowz_app",
    script: "bash",
    args: ["-lc", "export PORT=3004 && flox activate -- bash -lc 'flutter config --enable-web >/dev/null 2>&1 || true && flutter pub get && flutter run -d web-server --web-hostname 0.0.0.0 --web-port 3004'"],
    env: {
      PORT: 3004
    },
    autorestart: true,
    max_restarts: 3,
    min_uptime: "10s",
    restart_delay: 2000,
    watch: false
  }]
};
