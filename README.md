# 🚀 DSH Remote Setup

**Run your local DeepSeek Harness agent from your phone — from anywhere.**

A complete, end-to-end guide: install **DeepSeek Harness** (DSH) on a fresh Windows + WSL2 machine, then turn it into a remotely accessible host reachable from your phone — with the **full UI** (workspaces, sessions, history), exactly like on your desktop.

---

## 🤖 What is DeepSeek Harness (DSH)?

**DeepSeek Harness** is a **local-first AI agent harness** — think *Claude Code, but it runs entirely on your machine*.

- 🖥️ **100% local** — agents, sessions, workspaces, and history all live on your disk. Your data never leaves your machine.
- 🔧 **Model-agnostic** — you configure which models it talks to (e.g. DeepSeek, or any API-compatible provider).
- 📂 **Workspace-based** — each project folder is a workspace; sessions persist across restarts and keep working in the background.
- 🌐 **Web UI** — `dsh web` serves a full browser interface for managing sessions, agents, and goals.

> **DSH vs Claude Code:** Claude Code runs against Anthropic's cloud. DSH runs agents on *your* box, with *your* data, under *your* rules. The tradeoff: self-hosted means you handle the plumbing — which is exactly what this repo does for you.

---

## 📦 Part 1 — Install DeepSeek Harness (fresh machine)

### 1. WSL2 + Ubuntu (if you don't have it)

```powershell
wsl --install
```

### 2. Node.js ≥ 24 (via nvm)

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
nvm install 24
nvm alias default 24
```

> ⚠️ **Node 24 is required.** Node 12 (WSL's default on some setups) breaks `npx` native builds like `koffi`.

### 3. Install DeepSeek Harness

```bash
npm install -g @deepseek-ai/dsh
```

### 4. First run (local test)

```bash
dsh web
```

Open `http://127.0.0.1:3080` — you should see the harness UI.

---

## 🌍 Part 2 — Remote setup (one command)

```bash
curl -fsSL https://raw.githubusercontent.com/anggakersanamunggaran/dsh-remote-setup/main/setup.sh | bash
```

The script does all of this automatically:

| Step | What it does |
|---|---|
| 1 | Copies the `dshlan` scripts to `~/` |
| 2 | Adds the `dshlan` command to `~/.bashrc` |
| 3 | Verifies Node.js ≥ 24 |
| 4 | **Installs DeepSeek Harness** (`npm i -g @deepseek-ai/dsh`) if missing |
| 5 | Stages the Windows files (`dsh-lan.ps1` / `.cmd`) to `C:\Users\Public` |
| 6 | Prints the remaining manual steps (A–E) |

Then follow the printed steps:

- **A. Tailscale** — install on Windows, log in with the same account used on your phone, note the new IP (`tailscale ip -4`).
- **B. Windows (admin)** — install OpenSSH Server, allow port 22, set a Windows account password (SSH rejects blank passwords; keep auto-login via `netplwiz`), then run `dsh-lan.ps1` for the port-forward + firewall.
- **C. WSL** — `source ~/.bashrc && dshlan on` (auto-detects WSL/LAN/Tailscale IPs and starts DSH with the right `--trusted-host` flags).
- **D. Phone** — update the Termux alias with the new Tailscale IP.
- **E. Phone browser** — `http://127.0.0.1:3080`.

---

## 📱 Part 3 — Phone access (Android)

1. **Tailscale** on the phone (same account) — required, it's the secure path from anywhere.
2. **Termux** — install from [F-Droid](https://f-droid.org/packages/com.termux/) or GitHub. *Skip the Play Store build — it's abandoned and its SSL is broken.*
3. Install OpenSSH and set an alias:

```bash
pkg install openssh -y
echo "alias dsh='ssh -L 3080:127.0.0.1:3080 user@<TAILSCALE-IP>'" >> ~/.bashrc
source ~/.bashrc
```

4. Daily use:

```bash
dsh        # keeps the tunnel open
```

Then open `http://127.0.0.1:3080` in the phone browser.

---

## 🧠 How it works

- **DSH only binds `127.0.0.1`** (by design) → a Windows port-forward (`8080 → 127.0.0.1:3080`) rides WSL2's localhost relay — stable, never goes stale across reboots.
- DSH is launched with `--trusted-host` entries for your LAN IP, hostname, **and** Tailscale IP — auto-detected by `dshlan on`.
- **Tailscale** provides the secure any-any path (punches through NAT and ISP router AP isolation, works on mobile data).
- **SSH local port forwarding** makes the phone's browser see `127.0.0.1` → DSH's frontend boots in **full mode** → complete UI (this is the trick that makes it look identical to your desktop).

---

## 🧯 Troubleshooting

| Symptom | Fix |
|---|---|
| "Site can't be reached" | Check Tailscale is connected on the phone |
| "Connection refused" in SSH | `Start-Service sshd` (admin PowerShell) |
| 403 on `/api` | Missing `--trusted-host` — re-run `dshlan on` |
| "Address already in use" | Another process holds port 3080 — run `dshlan off` first |
| `koffi` build error during install | You're on node < 24 — run `nvm use 24` |
| Termux "SSL failed" / "unable to locate package" | Dead Play Store build — use F-Droid/GitHub version |

---

## 📄 License

MIT
