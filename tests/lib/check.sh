#! /usr/bin/env bash
# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

set -eu;
set -o pipefail;


# ---------------------------------------------------------------------------- #

: "${REALPATH:=realpath}";
: "${NIX:=nix}";

# ---------------------------------------------------------------------------- #

SPATH="$( $REALPATH "${BASH_SOURCE[0]}"; )";
SDIR="${SPATH%/*}";

# ---------------------------------------------------------------------------- #

[[ "$( $NIX eval --json -f "$SDIR"; )" == '[]' ]];


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
