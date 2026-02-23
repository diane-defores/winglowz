module.exports = {
  apps: [{
    name: "winflowz",
    cwd: "/home/claude/winflowz",
    script: "bash",
    args: ["-c", "export PORT=3002 && flox activate -- pnpm dev -- --port 3002"],
    env: {
      PORT: 3002
    },
    autorestart: true,
    watch: false
  }]
};
