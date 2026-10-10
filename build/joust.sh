#!/bin/sh
printf '\033c\033]0;%s\a' Joust
base_path="$(dirname "$(realpath "$0")")"
"$base_path/joust.x86_64" "$@"
