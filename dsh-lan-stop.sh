#!/bin/bash
# dsh-lan-stop.sh — "dshlan off": stop DSH and free the port.
# After this, plain 'dsh web' works again on 127.0.0.1:3080.
set -u

echo "▶ Stopping DSH..."
pkill -f 'dsh web' 2>/dev/null || true
for _ in $(seq 1 10); do
    ss -tln 2>/dev/null | grep -q ":3080 " || break
    sleep 1
done

if ss -tln 2>/dev/null | grep -q ":3080 "; then
    echo "⚠ Port 3080 still busy — force killing..."
    pkill -9 -f 'dsh web' 2>/dev/null || true
    sleep 1
fi

if ss -tln 2>/dev/null | grep -q ":3080 "; then
    echo "❌ Still busy. Check: ps -ef | grep dsh"
else
    echo "✅ DSH stopped — port 3080 free."
fi
echo
echo "   Plain 'dsh web' works again (localhost only)."
echo "   The Windows port-forward + firewall stay configured (harmless while DSH is off)."
echo "   To remove them too (admin PowerShell):"
echo "     netsh interface portproxy delete v4tov4 listenport=8080 listenaddress=0.0.0.0"
echo "     Remove-NetFirewallRule -DisplayName 'DSH remote'"
