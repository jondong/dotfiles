#==============================================================================
# Machine identity for powerlevel10k prompt
# Maps system hostname to a short display name and color.
#
# Naming convention:
#   mac-*    : macOS machines
#   desk     : local Linux desktop
#   bwg      : overseas cloud (Bandwagon)
#   tx-*     : domestic cloud (Tencent Cloud)
#
# Color pools by type (256-color codes):
#   Mac:         30-39  (blue/cyan family)
#   Local Linux: 28-36  (green family)
#   Overseas:    160-172 (orange/red family)
#   Domestic:    178-220 (yellow/gold family)
#
# To add a new machine:
#   1. Assign a hostname following the convention above
#   2. Pick an unused color from the matching family
#   3. Add a case entry below
#   4. Set the hostname on the new machine
#   5. Reload zsh: source ~/.zshrc
#==============================================================================

typeset -g MACHINE_NAME
typeset -g MACHINE_COLOR

case "$(hostname -s)" in
  # Mac fleet - blue/cyan family
  mac-p)   MACHINE_NAME="MAC-P"  ; MACHINE_COLOR=33  ;;  # blue
  mac-w)   MACHINE_NAME="MAC-W"  ; MACHINE_COLOR=37  ;;  # cyan
  mac-m)   MACHINE_NAME="MAC-M"  ; MACHINE_COLOR=62  ;;  # indigo

  # Local Linux - green family
  desk)    MACHINE_NAME="DESK"   ; MACHINE_COLOR=28  ;;  # green

  # Overseas cloud - orange/red family
  bwg)     MACHINE_NAME="BWG"    ; MACHINE_COLOR=166 ;;  # orange

  # Domestic cloud - yellow/gold family
  tx-prod) MACHINE_NAME="TX-PROD"; MACHINE_COLOR=220 ;;  # yellow
  tx-dev)  MACHINE_NAME="TX-DEV" ; MACHINE_COLOR=178 ;;  # gold

  # Fallback for unknown / new machines
  *)       MACHINE_NAME="$(hostname -s | tr '[:lower:]' '[:upper:]')"; MACHINE_COLOR=242 ;;
esac

# Custom p10k segment: colored machine identity badge
function prompt_machine_alias() {
  p10k segment -b "$MACHINE_COLOR" -f 255 -t "$MACHINE_NAME"
}
