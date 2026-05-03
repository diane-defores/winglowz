module.exports = {
  apps: [{
    name: "winflowz",
    cwd: "/home/ubuntu/winflowz",
    script: "bash",
    args: ["-lc", "export PORT=3013 && flox activate -- bash -lc 'npm run dev -- --port 3013'"],
    env: {
      PORT: 3013
    },
    autorestart: true,
    watch: false
  }]
};
