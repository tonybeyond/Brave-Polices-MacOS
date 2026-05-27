# Brave Origin — Free on macOS via Managed Policies

Reproduce the [Brave Origin](https://support.brave.app/hc/en-us/articles/38561489788173-What-is-Brave-Origin) experience on macOS **for free**, using native managed preferences — no MDM, no purchase required.

> **Brave Origin** is a stripped-down version of Brave that disables all revenue-generating and telemetry features. It is officially free on Linux only, and a one-time $60 purchase on macOS/Windows. This repo achieves the same result using macOS policy files.

---

## What gets disabled

| Feature | Policy key |
|---|---|
| Leo (AI Chat) | `BraveAIChatEnabled` → false |
| News | `BraveNewsDisabled` → true |
| Playlist | `BravePlaylistEnabled` → false |
| Rewards + Brave Ads | `BraveRewardsDisabled` → true |
| Speedreader | `BraveSpeedreaderEnabled` → false |
| P3A analytics | `BraveP3AEnabled` → false |
| Daily usage ping | `BraveStatsPingEnabled` → false |
| Talk | `BraveTalkDisabled` → true |
| Tor | `TorDisabled` → true |
| VPN | `BraveVPNDisabled` → true |
| Wallet + Web3 domains | `BraveWalletDisabled` → true |
| Wayback Machine | `BraveWaybackMachineEnabled` → false |
| Web Discovery Project | `BraveWebDiscoveryEnabled` → false |

## What is preserved

- ✅ Brave Sync
- ✅ Chrome extension support (Chrome Web Store)
- ✅ Brave Shields (adblock, fingerprinting protection, HTTPS upgrade)
- ✅ Automatic browser updates

---

## Quick start

```bash
git clone https://github.com/tonybeyond/Brave-Polices-MacOS.git
cd brave-origin-free-macos
chmod +x brave-policies-apply.sh
sudo ./brave-policies-apply.sh
```

Then open `brave://policy` in Brave — all keys should appear with status **OK**.

---

## How it works

macOS supports machine-level managed preferences at `/Library/Managed Preferences/`. Chromium-based browsers (including Brave) read policy files from this directory at startup, applying them with **Mandatory** priority — they override any user-facing settings and survive browser updates.

The script:
1. Checks whether the policy file already exists
2. Gracefully closes any running Brave instance
3. Writes all policy keys via `defaults write`
4. Sets correct ownership (`root:wheel`) and permissions (`644`)
5. Reopens Brave under the current user session

### Persistence caveat

On macOS Ventura and later, `/Library/Managed Preferences/` may be cleared on reboot without an active MDM enrollment. If policies disappear after a restart, set up the script as a **LaunchDaemon**:

```bash
sudo cp com.brave.policies.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/com.brave.policies.plist
sudo chmod 644 /Library/LaunchDaemons/com.brave.policies.plist
sudo launchctl load /Library/LaunchDaemons/com.brave.policies.plist
```

The included `com.brave.policies.plist` LaunchDaemon runs `brave-policies-apply.sh` at every boot.

---

## Manual settings (not enforceable via policy)

A few items require manual configuration in `brave://settings/privacy`:

| Setting | Value |
|---|---|
| Automatically send diagnostic reports | **OFF** |
| WebRTC IP handling policy | **Disable non-proxied UDP** |
| Use Google services for push messaging | **OFF** |

And via Terminal (background mode):

```bash
defaults write com.brave.Browser BackgroundModeEnabled -bool false
```

---

## Files

```
.
├── brave-policies-apply.sh       # Main script — apply/update all policies
├── com.brave.policies.plist      # LaunchDaemon for boot persistence
└── README.md
```

---

## Limitations

Unlike the paid Brave Origin standalone build, this approach **disables** features at runtime but does not **remove** them from the binary. The code is still present — only execution is blocked. For everyday use, the difference is purely theoretical.

---

## Compatibility

Tested on macOS Sonoma 14.x and Sequoia 15.x with Brave stable channel.  
Requires `sudo` for writing to `/Library/Managed Preferences/`.

---

## License

MIT
