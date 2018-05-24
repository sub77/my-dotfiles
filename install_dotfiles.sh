#!/usr/bin/env bash

IFS=$'\12'

emy="\033[1;33m"
red="\033[91m"
none="\033[0m"

# Show how to use this installer
function show_usage() {
  echo -e "${emy}Usage:${none}\n${0##*/} [arguments] \n"
  echo -e "${emy}Arguments:${none}"
  echo "--help (-h): Display this help message"
  echo "--install (-i): Install default settings without prompting for input";
  exit 0;
}

for param in "$@"; do
  shift
  case "$param" in
    "--help")               set -- "$@" "-h" ;;
    "--install")            set -- "$@" "-i" ;;
    *)                      set -- "$@" "$param"
  esac
done

OPTIND=1
while getopts "hi" opt
do
  case "$opt" in
  "h") show_usage; exit 0 ;;
  "i") install=true ;;
  "?") show_usage >&2; exit 1 ;;
  esac
done
# Default option
if (( $OPTIND == 1 )); then
  install=true
fi
shift $(expr $OPTIND - 1)

if [[ $install ]]; then
  pip install --user dotfiles
  repo="https://github.com/${USER}/my-dotfiles"
  read -e -i "$repo" -p "Repository: " input
  repo="${input:-$repo}"
  target="${HOME}/Dotfiles"
  read -e -i "$target" -p "Target: " input
  target="${input:-$target}"
  if [[ -d $target ]]; then
    echo "Directory exists"
  else
    git clone $repo $target
  fi
  ln -sf $target/.dotfilesrc ${HOME}/.dotfilesrc
  sed -i '/repository/d' ${HOME}/.dotfilesrc
  sed -i "/\[dotfiles\]/a repository = $target" ${HOME}/.dotfilesrc
  dotfiles --sync
  exit 1
fi

