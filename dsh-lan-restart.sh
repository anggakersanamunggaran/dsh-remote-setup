#!/bin/bash
# dsh-lan-restart.sh — "dshlan on": start DSH in LAN mode so your phone can reach it.
#
# Architecture (corrected & proven): DSH can ONLY bind 127.0.0.1, so it stays on
# loopback and is started with --trusted-host for your LAN names. The Windows
# port-forward (0.0.0.0:8080 -> 127.0.0.1:3080) rides WSL2's localhost relay —
# the same path your Chrome already uses. No WSL IP, no forwarder, never stale.
#
# Note: this stops the currently running DSH (the old browser tab disconnects;
# the conversation survives — reconnect at any URL below).
set -u

# ⬇ node 24 fix — node 12 (WSL's default) breaks npx native builds (koffi@3.x).
# Always run under node 24 (or the newest installed LTS) before touching npx.
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
if command -v nvm >/dev/null 2>&1; then
    nvm use 24 >/dev/null 2>&1 || nvm use --lts >/dev/null 2>&1 || true
fi
# fallback if nvm is unavailable: newest installed nvm node
if ! command -v node >/dev/null 2>&1; then
    newest=$(ls -d "$HOME"/.nvm/versions/node/*/bin 2>/dev/null | sort -V | tail -1)
    [ -n "${newest:-}" ] && export PATH="$newest:$PATH"
fi
echo "   using node $(node --version 2>/dev/null || echo unknown) → $(command -v node 2>/dev/null)"

WIN_IP=$(/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command \
    "(Get-NetIPConfiguration | Where-Object { \$_.IPv4DefaultGateway -ne \$null -and \$_.NetAdapter.Status -eq 'Up' } | Select-Object -First 1).IPv4Address.IPAddress" 2>/dev/null | tr -d '\r')
WIN_HOST=$(/mnt/c/Windows/System32/hostname.exe 2>/dev/null | tr -d '\r')
TS_IP=$("/mnt/c/Program Files/Tailscale/tailscale.exe" ip -4 2>/dev/null | tr -d '\r' | head -1)

echo "   LAN IP    : ${WIN_IP:-<not detected>}"
echo "   Tailscale : ${TS_IP:-<not installed>}"

echo "▶ Stopping any running DSH (old session ends)..."
pkill -f 'dsh web' 2>/dev/null || true
for _ in $(seq 1 10); do
    ss -tln 2>/dev/null | grep -q ":3080 " || break
    sleep 1
done

echo "▶ Starting DSH on 127.0.0.1:3080 with LAN trusted hosts..."
TRUSTED=(--trusted-host dshlocal.test --trusted-host "${WIN_HOST}.local" --trusted-host "${WIN_IP}")
[ -n "${TS_IP:-}" ] && TRUSTED+=(--trusted-host "$TS_IP")
nohup npx @deepseek-ai/dsh web "${TRUSTED[@]}" > "$HOME/dsh-lan.log" 2>&1 &

for _ in $(seq 1 20); do
    ss -tln 2>/dev/null | grep -q ":3080 " && break
    sleep 1
done

if ! ss -tln 2>/dev/null | grep -q ":3080 "; then
    echo "⚠ DSH failed to start — last log lines:"
    tail -5 "$HOME/dsh-lan.log" 2>/dev/null
    exit 1
fi
echo "✅ DSH listening on 127.0.0.1:3080"

echo "▶ Checking the Windows port-forward (8080 -> 127.0.0.1:3080)..."
PROXY=$(/mnt/c/Windows/System32/netsh.exe interface portproxy show all 2>/dev/null)
if echo "$PROXY" | grep -q "127.0.0.1" && echo "$PROXY" | grep -q "3080"; then
    echo "   already correct."
else
    echo "   missing or stale — a UAC prompt will appear, click Yes:"
    cmd.exe /c "C:\\Users\\Public\\dsh-lan.cmd" >/dev/null 2>&1 || true
fi

echo
echo "✅ LAN mode ON — URLs:"
echo "   Phone AND PC:  http://${WIN_IP:-192.168.1.x}:8080"
echo "   Tailscale:     http://${TS_IP:-100.x.x.x}:8080   (anywhere, no router needed)"
echo "   Pretty name:   http://dshlocal.test:8080   (PC: hosts file · phone: router DNS)"
echo "   mDNS:          http://${WIN_HOST:-PC}.local:8080"
echo "   Local (PC):    http://127.0.0.1:3080   (unchanged)"
echo
echo "   While in LAN mode, don't run plain 'dsh web' — use 'dshlan off' first."
