module.exports = {
  apps: [{
    name: "winflowz",
    cwd: "/home/claude/winflowz",
    script: "bash",
    args: ["-c", "export PORT=3011 && flox activate -- pnpm dev -- --port 3011"],
    env: {
      PORT: 3011
    },
    autorestart: true,
    watch: false
  }]
};
