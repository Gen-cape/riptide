#!/usr/bin/env bash

# Interactively run Nix build phases.
# This script must be sourced in Nix development shell environment!

# USAGE:
# mkdir dev; cd dev
# nix develop nixpkgs#<PACKAGE>
# source nix-develop-interactive.bash

# Color definitions
RED='\033[38;2;248;21;98m'    # #f81562
BLUE='\033[38;2;93;244;251m'  # #5df4fb
RESET='\033[0m'

# Ensure script is sourced
if ! (return 0 2>/dev/null); then
    echo -e "${RED}ERROR:${RESET} this script must be sourced (run 'source $0')."
    exit 1
fi

# Ensure we're in a nix shell
if ! type -t genericBuild &>/dev/null; then
    echo -e "${RED}ERROR:${RESET} this script must be sourced from nix shell environment (run 'nix develop nixpkgs#<PACKAGE>')."
    return 1
fi

export SHELL=$(which bash)

# Combine all phases
all_phases="${prePhases[*]:-} unpackPhase patchPhase ${preConfigurePhases[*]:-} \
    configurePhase ${preBuildPhases[*]:-} buildPhase checkPhase \
    ${preInstallPhases[*]:-} installPhase ${preFixupPhases[*]:-} fixupPhase installCheckPhase \
    ${preDistPhases[*]:-} distPhase ${postPhases[*]:-}"

# Function to format phase display
format_phases() {
    local current_phase=$1
    local phases=($all_phases)
    local output=""

    for phase in "${phases[@]}"; do
        if [ "$phase" = "$current_phase" ]; then
            output+="${RED}[$phase]${RESET} "
        else
            output+="${BLUE}[$phase]${RESET} "
        fi
    done

    echo "$output"
}

# Run phases
for phase in $all_phases; do
    echo -e "\n${RED}  >>>${RESET} Phase:   $(format_phases "$phase")"
    echo -e "${RED}  >>>${RESET} Command:  phases=${RED}${phase}${RESET} genericBuild"
    echo -e "${RED}  >>>${RESET} Press ENTER to run, CTRL-C to exit"
    read || exit 1

    phases=$phase genericBuild
done
