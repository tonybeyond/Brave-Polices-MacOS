#!/bin/bash

# ─────────────────────────────────────────────
# Brave Policy Enforcer
# Usage : sudo ./brave-policies-apply.sh
# ─────────────────────────────────────────────

PLIST="/Library/Managed Preferences/com.brave.Browser.plist"
BRAVE_APP="Brave Browser"

# ── Root check ────────────────────────────────
if [[ $EUID -ne 0 ]]; then
  echo "❌  Ce script doit être lancé avec sudo."
  exit 1
fi

echo "🔍  Vérification du fichier de policy..."

# ── État initial ──────────────────────────────
if [[ -f "$PLIST" ]]; then
  echo "✅  Fichier existant — mise à jour en cours."
else
  echo "⚠️   Fichier absent — création en cours."
fi

# ── Fermeture de Brave ────────────────────────
if pgrep -x "$BRAVE_APP" &>/dev/null; then
  echo "🛑  Fermeture de Brave..."
  osascript -e "quit app \"$BRAVE_APP\""
  sleep 2
  # Force kill si toujours actif
  pkill -x "$BRAVE_APP" 2>/dev/null
  echo "    Brave fermé."
else
  echo "ℹ️   Brave n'est pas en cours d'exécution."
fi

# ── Application des policies ──────────────────
echo "📝  Écriture des policies..."

/usr/bin/defaults write "$PLIST" BraveAIChatEnabled        -bool false
/usr/bin/defaults write "$PLIST" BraveNewsDisabled          -bool true
/usr/bin/defaults write "$PLIST" BravePlaylistEnabled       -bool false
/usr/bin/defaults write "$PLIST" BraveRewardsDisabled       -bool true
/usr/bin/defaults write "$PLIST" BraveSpeedreaderEnabled    -bool false
/usr/bin/defaults write "$PLIST" BraveP3AEnabled            -bool false
/usr/bin/defaults write "$PLIST" BraveStatsPingEnabled      -bool false
/usr/bin/defaults write "$PLIST" BraveTalkDisabled          -bool true
/usr/bin/defaults write "$PLIST" TorDisabled                -bool true
/usr/bin/defaults write "$PLIST" BraveVPNDisabled           -bool true
/usr/bin/defaults write "$PLIST" BraveWalletDisabled        -bool true
/usr/bin/defaults write "$PLIST" BraveWaybackMachineEnabled -bool false
/usr/bin/defaults write "$PLIST" BraveWebDiscoveryEnabled   -bool false
/usr/bin/defaults write "$PLIST" SyncDisabled               -bool false

# ── Permissions ───────────────────────────────
/bin/chmod 644 "$PLIST"
/usr/sbin/chown root:wheel "$PLIST"
echo "🔒  Permissions appliquées (root:wheel 644)."

# ── Vérification rapide ───────────────────────
echo ""
echo "📋  Policies actives :"
/usr/bin/defaults read "$PLIST"

# ── Réouverture de Brave ──────────────────────
echo ""
echo "🚀  Réouverture de Brave..."
sudo -u "$SUDO_USER" open -a "$BRAVE_APP"

echo ""
echo "✅  Terminé. Vérifier brave://policy pour confirmer."
