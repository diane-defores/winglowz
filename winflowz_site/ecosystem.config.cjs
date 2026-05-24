module.exports = {
  apps: [{
    name: "winflowz",
    cwd: "/home/claude/winflowz",
    script: "bash",
    args: ["-lc", "export PORT=3013 && flox activate -- bash -lc 'pnpm dev -- --port 3013'"],
    env: {
      PORT: 3013
    },
    autorestart: true,
    max_restarts: 3,
    min_uptime: "10s",
    restart_delay: 2000,
    watch: false
  }]
};
