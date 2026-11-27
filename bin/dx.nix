#!/usr/bin/env bash
# vim: ft=bash

set -o errexit -o nounset -o pipefail -o errtrace
(shopt -p inherit_errexit &>/dev/null) && shopt -s inherit_errexit

PROGRAM="${0##*/}"
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

usage() {
  cat <<EOF
Usage:
  $PROGRAM <command> [options]

Commands:
  switch                  Build and activate configuration
  build                   Build configuration
  activate
  eval
  update [input-name]     Update the input flake
  help                    Show this help

Options:
  -h, --help    Show help
EOF
}

die() {
  printf '%s: %s\n' "$PROGRAM" "$*" >&2
  exit 1
}

command="${1:-help}"

if (($# > 0)); then
  shift
fi

case "$command" in
help | -h | --help)
  usage
  ;;

*)
  script="$SCRIPT_DIR/cmds/$command"

  [[ -x "$script" ]] || die "Unknown command: $command (run '$PROGRAM help')"
  exec "$script" "$@"
  ;;
esac
