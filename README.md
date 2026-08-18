# 🚀 DSH Remote Setup

**Run your local DeepSeek Harness agent from your phone — from anywhere.**

One-command installer that turns any Windows + WSL2 machine into a remotely accessible DeepSeek Harness host, reachable from your phone over Tailscale + SSH tunnel — with the **full UI** (workspaces, sessions, history), exactly like on your desktop.

## ✨ Quick start (new machine)

```bash
curl -fsSL https://raw.githubusercontent.com/anggakersanamunggaran/dsh-remote-setup/main/setup.sh | bash
```

The script copies the scripts, adds the `dshlan` command to your `~/.bashrc`, verifies Node.js ≥ 24, stages the Windows files, and prints the remaining steps (A–E) for Windows, Tailscale, and your phone.

## 📦 What's included

| File | Purpose |
|---|---|
| `setup.sh` | One-shot installer (run it, follow the printed steps) |
| `dsh-lan-restart.sh` | `dshlan on` — start DSH in remote mode (auto-detects WSL/LAN/Tailscale IPs) |
| `dsh-lan-stop.sh` | `dshlan off` — stop DSH |
| `dsh-lan.ps1` / `dsh-lan.cmd` | Windows port-forward `0.0.0.0:8080 → 127.0.0.1:3080` + firewall rule (run as admin) |

## 🧠 How it works

- **DSH only binds `127.0.0.1`** (by design) → a Windows port-forward (`8080 → 127.0.0.1:3080`) rides WSL2's localhost relay — stable, never goes stale across reboots.
- DSH is launched with `--trusted-host` entries for your LAN IP, hostname, **and** Tailscale IP — all auto-detected by `dshlan on`.
- **Tailscale** provides the secure any-any path (punches through NAT and ISP router AP isolation, works on mobile data).
- **SSH local port forwarding** (`ssh -L 3080:127.0.0.1:3080`) from your phone makes the phone's browser see `127.0.0.1` → DSH's frontend boots in full mode → complete UI on your phone.

## ✅ Prerequisites

- Windows 10/11 + WSL2 + Node.js **≥ 24** (node 12 breaks npx native builds like `koffi`)
- Tailscale on PC and phone (same account)
- Windows account with a **password** (SSH rejects blank passwords) — auto-login can be preserved via `netplwiz`
- Android phone: **Termux** (install from F-Droid / GitHub — the Play Store build is abandoned and its SSL is broken)

## 📱 Daily usage

1. Tailscale ON (phone)
2. `dsh` in Termux (alias for `ssh -L 3080:127.0.0.1:3080 user@<tailscale-ip>`)
3. Open `http://127.0.0.1:3080` on the phone

## 🧯 Troubleshooting

| Symptom | Fix |
|---|---|
| "Site can't be reached" | Check Tailscale is connected on the phone |
| "Connection refused" in SSH | `Start-Service sshd` (admin PowerShell) |
| 403 on `/api` | Missing `--trusted-host` — re-run `dshlan on` |
| "Address already in use" | Another process holds port 3080 — run `dshlan off` first |
| Termux "SSL failed" / "unable to locate package" | You're on the dead Play Store build — use F-Droid/GitHub version |

## 📄 License

MIT
