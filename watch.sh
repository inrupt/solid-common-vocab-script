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

# Get the directory this script itself is located in.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DEFAULT_TARGET_DIR="src/SolidCommonVocab"
TARGET_DIR="${PWD}/${DEFAULT_TARGET_DIR}"
BINARY_DIR="Bin"
VOCAB_DIR="Vocab"
REPO_DIR=""
GENERATED_DIR="${TARGET_DIR}/Generated"

source ${SCRIPT_DIR}/run_command.sh

helpFunction() {
    printf "${BLUE}Usage: $0 [ -t <TargetDirectory for vocabulary source code> -r <RepositoryDirectory to watch> -g <GeneratedDirectory to generate source code into> ]\n"
    printf "Executes the Artifact Generator to watch all RDF vocabularies referenced in all the YAML files found within the RepositoryDirectory inside the TargetDirectory, and generate source-code into the GeneratedDirectory.${NORMAL}\n\n"
    printf "${BLUE}Options:${NORMAL}\n"
    printf "\t-r ${BLUE}Repository directory (default is: [${REPO_DIR}])${NORMAL}\n"
    printf "\t-t ${YELLOW}Optional: ${BLUE}Target directory (default is: [${TARGET_DIR}])${NORMAL}\n"
    printf "\t-g ${YELLOW}Optional: ${BLUE}Generated directory (default is: [${GENERATED_DIR}])${NORMAL}\n\n"
    printf "${YELLOW}Current working directory: [${PWD}]${NORMAL}\n"
    printf "${YELLOW}Target directory: [${TARGET_DIR}]${NORMAL}\n"
    printf "${YELLOW}Script directory: [${SCRIPT_DIR}]${NORMAL}\n\n"
}

if [ "${1:-}" == "?" ] || [ "${1:-}" == "-?" ] || [ "${1:-}" == "-h" ] || [ "${1:-}" == "--help" ]
then
    helpFunction
    exit 1 # Exit script after printing help.
fi

while getopts ":t:r:g:" opt
do
    case "$opt" in
      t ) TARGET_DIR=$OPTARG ;;
      r ) REPO_DIR=$OPTARG ;;
      g ) GENERATED_DIR=$OPTARG ;;
      \? ) helpFunction ;; # Print help in case parameter is non-existent
    esac
done

if [ "${REPO_DIR:-}" == "" ]
then
    printf "${RED}You *MUST* provide a Repository directory (-r option) to watch from.${NORMAL}\n\n"
    helpFunction
    exit 1 # Exit script after printing help.
fi

#run_command "${SCRIPT_DIR}/fetchLag.sh"

printf "\n${GREEN}Running AG as Watcher: [node ${TARGET_DIR}/${BINARY_DIR}/artifact-generator/index.js watch --vocabListFile \"${TARGET_DIR}/${VOCAB_DIR}/${REPO_DIR}/**/*.yml\" --outputDirectory $\"{GENERATED_DIR}\"]...${NORMAL}\n"

#
# Note: notice the need to delimit filenames here with double quotes. Not doing so causes weird
# yargs processing errors (possibly due to the asterisks?).
#
node ${TARGET_DIR}/${BINARY_DIR}/artifact-generator/index.js watch --vocabListFile "${TARGET_DIR}/${VOCAB_DIR}/${REPO_DIR}/**/*.yml" --outputDirectory "${GENERATED_DIR}"
