#!/usr/bin/env bash
# setup.sh — DSH Remote Setup: sekali jalan di laptop baru.
#
#   Cara pakai (setelah repo ini di GitHub):
#     curl -fsSL https://raw.githubusercontent.com/anggakersanamunggaran/dsh-remote-setup/main/setup.sh | bash
#
# Yang dilakukan:
#   1. Menyalin script dshlan (on/off) ke ~/
#   2. Menambahkan fungsi `dshlan` ke ~/.bashrc
#   3. Mengecek Node.js >= 24 (wajib buat DSH)
#   4. Menginstall DeepSeek Harness (dsh) secara global
#   5. Menyalin file Windows (dsh-lan.ps1/.cmd) ke C:\Users\Public
#   6. Mencetak langkah Windows + HP yang tersisa
set -u

GITHUB_USER="anggakersanamunggaran"

echo "=================================================="
echo "  DSH Remote Setup — installer"
echo "=================================================="

# 1) Script dshlan
echo ""
echo "[1/6] Menyalin script dshlan ke ~/ ..."
if [ -f "./dsh-lan-restart.sh" ] && [ -f "./dsh-lan-stop.sh" ]; then
    cp ./dsh-lan-restart.sh ./dsh-lan-stop.sh "$HOME/"
    echo "  OK (dari folder repo)"
else
    echo "  (folder repo tidak ada — unduh dari GitHub)"
    curl -fsSL -o "$HOME/dsh-lan-restart.sh" "https://raw.githubusercontent.com/${GITHUB_USER}/dsh-remote-setup/main/dsh-lan-restart.sh" || { echo "  ❌ gagal unduh — cek GITHUB_USER di bagian atas setup.sh"; exit 1; }
    curl -fsSL -o "$HOME/dsh-lan-stop.sh" "https://raw.githubusercontent.com/${GITHUB_USER}/dsh-remote-setup/main/dsh-lan-stop.sh" || { echo "  ❌ gagal unduh"; exit 1; }
fi
chmod +x "$HOME/dsh-lan-restart.sh" "$HOME/dsh-lan-stop.sh"

# 2) Fungsi dshlan di .bashrc
echo "[2/6] Menambahkan fungsi dshlan ke ~/.bashrc ..."
if grep -q "^dshlan()" "$HOME/.bashrc" 2>/dev/null; then
    echo "  (sudah ada — dilewati)"
else
    cat >> "$HOME/.bashrc" <<'EOF'

# 🚀 dshlan — DSH remote on/off (dari dsh-remote-setup)
dshlan() {
    case "${1:-}" in
        on)  bash "$HOME/dsh-lan-restart.sh" ;;
        off) bash "$HOME/dsh-lan-stop.sh" ;;
        *)   echo "Usage: dshlan on | off";;
    esac
}
EOF
    echo "  OK — jalankan: source ~/.bashrc"
fi

# 3) Node.js check
echo "[3/6] Mengecek Node.js ..."
if command -v node >/dev/null 2>&1 && [ "$(node --version | tr -dc '0-9' | cut -c1-2)" -ge 24 ]; then
    echo "  ✅ node $(node --version)"
else
    echo "  ⚠️ Node < 24 atau belum ada. Pasang dulu via nvm:"
    echo "     curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash"
    echo "     nvm install 24 && nvm alias default 24"
    echo "  lalu jalankan ulang setup ini."
    exit 1
fi

# 4) Install DeepSeek Harness (dsh)
echo "[4/6] Menginstall DeepSeek Harness (dsh) ..."
if command -v dsh >/dev/null 2>&1; then
    echo "  ✅ dsh sudah terinstall: $(command -v dsh)"
else
    echo "  Menginstall: npm install -g @deepseek-ai/dsh"
    npm install -g @deepseek-ai/dsh 2>&1 | tail -2
    if command -v dsh >/dev/null 2>&1; then
        echo "  ✅ dsh terinstall: $(command -v dsh)"
    else
        echo "  ⚠️ Install dsh gagal — cek error di atas, atau jalankan manual:"
        echo "     npm install -g @deepseek-ai/dsh"
    fi
fi

# 5) File Windows
echo "[5/6] Menyiapkan file Windows di C:\\Users\\Public ..."
for f in dsh-lan.ps1 dsh-lan.cmd; do
    if [ -f "./$f" ]; then
        cp "./$f" /mnt/c/Users/Public/ 2>/dev/null && echo "  ✅ $f -> C:\\Users\\Public\\$f" || echo "  (lewatkan — jalankan dari folder repo nanti)"
    fi
done

# 6) Panduan
echo ""
echo "[6/6] ══════════ LANGKAH BERIKUTNYA ══════════"
echo ""
echo " DeepSeek Harness (dsh) SUDAH terinstall. Tes lokal dulu:"
echo "   dsh web   → buka http://127.0.0.1:3080"
echo ""
echo " A. TAILSCALE (di Windows):"
echo "    1. Install https://tailscale.com/download — login dengan AKUN SAMA"
echo "    2. Catat IP baru:  tailscale ip -4   (contoh: 100.88.11.22)"
echo ""
echo " B. WINDOWS — PowerShell ADMIN:"
echo "    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0"
echo "    Start-Service sshd"
echo "    Set-Service -Name sshd -StartupType Automatic"
echo "    New-NetFirewallRule -Name OpenSSH -DisplayName 'OpenSSH Server' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 22"
echo ""
echo "    # lalu bikin password akun Windows (Settings > Accounts > Sign-in"
echo "    # options > Password) dan jalankan port-forward DSH:"
echo "    powershell -ExecutionPolicy Bypass -File C:\\Users\\Public\\dsh-lan.ps1"
echo ""
echo " C. DSH LAN MODE (di WSL):"
echo "    source ~/.bashrc"
echo "    dshlan on"
echo ""
echo " D. HP (Termux) — ganti IP alias dengan IP Tailscale baru:"
echo "    nano ~/.bashrc"
echo "    alias dsh='ssh -L 3080:127.0.0.1:3080 user@<IP-TAILSCALE-BARU>'"
echo "    source ~/.bashrc"
echo "    dsh"
echo ""
echo " E. Browser HP:  http://127.0.0.1:3080"
echo "══════════════════════════════════════════════"
