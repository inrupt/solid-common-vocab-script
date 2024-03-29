#!/bin/bash
# set -e to exit on error.
set -e
# set -u to error on unbound variable (use ${var:-} to check if 'var' is set.
set -u
set -o pipefail

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
NORMAL=$(tput sgr0)

source ./run_command.sh

helpFunction()
{
    printf "${BLUE}Usage: $0 <Feature label to checkout>, e.g. $0 feat/latest-java-vocab-term${NORMAL}"
}


if [ "${1:-}" == "" ] || [ "${1:-}" == "?" ] || [ "${1:-}" == "-?" ] || [ "${1:-}" == "-h" ] || [ "${1:-}" == "--help" ]
then
    helpFunction
    exit 1 # Exit script after printing help.
fi

printf "Fetching latest 'main', and checking out branch: $1...\n"
run_command "git checkout main"
run_command "git fetch"
run_command "git rebase origin/main"
run_command "git checkout -b $1"
