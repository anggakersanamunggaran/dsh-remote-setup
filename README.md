# DSH Remote Setup 🚀

Akses **DeepSeek Harness** (AI agent lokal di WSL2/Windows) dari HP — di mana saja.

## Cara pakai di laptop baru (sekali jalan)

```bash
curl -fsSL https://raw.githubusercontent.com/anggakersanamunggaran/dsh-remote-setup/main/setup.sh | bash
```

Lalu ikuti langkah A–E yang dicetak script (Tailscale → OpenSSH → `dshlan on` → alias di HP).

## Yang ada di repo ini

| File | Fungsi |
|---|---|
| `setup.sh` | Installer sekali jalan (copy script, tambah `dshlan`, cek Node 24, cetak panduan) |
| `dsh-lan-restart.sh` | "dshlan on" — start DSH dalam LAN mode (auto-detect IP WSL/LAN/Tailscale) |
| `dsh-lan-stop.sh` | "dshlan off" — stop DSH |
| `dsh-lan.ps1` / `dsh-lan.cmd` | Port-forward Windows `8080 → 127.0.0.1:3080` + firewall (admin) |

## Arsitektur singkat

- DSH hanya bisa bind `127.0.0.1` (by design) → Windows port-forward `0.0.0.0:8080 → 127.0.0.1:3080` (via WSL2 localhost relay, anti-stale).
- DSH dijalankan dengan `--trusted-host` (LAN IP, hostname, dan IP Tailscale — otomatis dideteksi).
- **Tailscale** = jalur aman dari mana saja (tembus NAT & AP isolation router).
- **SSH tunnel** (`ssh -L 3080:127.0.0.1:3080`) dari HP → browser HP melihat origin `127.0.0.1` → frontend DSH boot penuh (workspace & session muncul).

## Syarat

- Windows + WSL2 + Node.js ≥ 24 (node 12 bikin npx gagal build koffi)
- Tailscale di PC & HP (akun sama)
- Akun Windows ber-password (SSH menolak password kosong)
- HP Android: Termux (dari F-Droid/GitHub — versi Play Store sudah mati)
