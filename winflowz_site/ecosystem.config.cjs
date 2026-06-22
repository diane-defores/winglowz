module.exports = {
  apps: [{
    name: "winflowz_site",
    cwd: "/home/claude/winflowz/winflowz_site",
    script: "bash",
    args: ["-lc", "export PORT=3005 && flox activate -- bash -lc 'pnpm dev -- --port 3005'"],
    env: {
      PORT: 3005
    },
    autorestart: true,
    max_restarts: 3,
    min_uptime: "10s",
    restart_delay: 2000,
    watch: false
  }]
};
