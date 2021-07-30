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
source ${SCRIPT_DIR}/run_command.sh


# Default AG directory is in a sibling directory of this script's directory.
AG_DIR="${SCRIPT_DIR}/../bin"

# Default vocabulary configuration root directory (e.g. from which we expect to
# crawl recursively for YAMLs that bundle multiple RDF vocabularies) is in a
# sibling directory of this script's directory.
VOCAB_CONFIG_DIR="${SCRIPT_DIR}"

# This default target directory is assuming we are running this script from
# within an application from which we've been making local updates to RDF
# vocabularies that we've cloned into the same place.
DEFAULT_TARGET_DIR="src/SolidCommonVocab"
TARGET_DIR="${PWD}/${DEFAULT_TARGET_DIR}"

# The One-Time-Password value to use for NPM (to satisfy 2FA)
NPM_OTP_VALUE="NONE"

PUBLISH_LOCAL=false
PUBLISH_REMOTE=false

helpFunction() {
    printf "Usage: $0 [ -t <TargetDirectory> ] [ -g <GeneratorDirectory> ] [ -v <VocabConfigRootDirectory> ] [ -l | -r ]\n"
    printf "${BLUE}Executes the Artifact Generator to re-generate and publish artifacts from all YAML files found from here.${NORMAL}\n"
    printf "${BLUE}Options:${NORMAL}\n"
    printf "\t-t ${YELLOW}Optional: ${BLUE}Target directory (default is: [${TARGET_DIR}])${NORMAL}\n"
    printf "\t-g ${YELLOW}Optional: ${BLUE}Artifact Generator directory (default is: [${AG_DIR}])${NORMAL}\n"
    printf "\t-v ${YELLOW}Optional: ${BLUE}Root directory to search for AG YAML files (default is: [${VOCAB_CONFIG_DIR}])${NORMAL}\n"
    printf "\t-o ${YELLOW}Optional: ${BLUE}The One-Time-Password value to use for NPM (to satisfy 2FA) (default is: [${NPM_OTP_VALUE}])${NORMAL}\n"
    printf "\t-l ${BLUE}Publish locally${NORMAL}\n"
    printf "\t-r ${BLUE}Publish remotely${NORMAL}\n\n"
}

while getopts ":t:g:v:o:lr" opt
do
    case "$opt" in
      t ) TARGET_DIR="$OPTARG" ;;
      g ) AG_DIR="$OPTARG" ;;
      v ) VOCAB_CONFIG_DIR="$OPTARG" ;;
      o ) NPM_OTP_VALUE="$OPTARG" ;;
      l ) PUBLISH_LOCAL=true ;;
      r ) PUBLISH_REMOTE=true ;;
      ? ) helpFunction ;; # Print help in case parameter is non-existent
    esac
done

if [ "${1:-}" == "?" ] || [ "${1:-}" == "-?" ] || [ "${1:-}" == "-h" ] || [ "${1:-}" == "--help" ]
then
    helpFunction
    exit 1 # Exit script after printing help.
fi

if [ "${PUBLISH_LOCAL}" == false ] && [ "${PUBLISH_REMOTE}" == false ]
then
    printf "${RED}You *MUST* stipulate whether to publish locally (the -l option) or remotely (the -r option).${NORMAL}\n\n"
    helpFunction
    exit 1 # Exit script after printing help.
fi

# Make sure we have the latest Artifact Generator.
${SCRIPT_DIR}/fetchLag.sh -t ${AG_DIR}

if [ "${PUBLISH_LOCAL}" == true ]
then
    printf "\n${BLUE}Executing the Artifact Generator to re-generate and re-publish ${RED}(LOCALLY)${BLUE} artifacts from all YAML files found from [${SCRIPT_DIR}].${NORMAL}\n"
    run_command "node ${AG_DIR}/artifact-generator/index.js generate --vocabListFile ${VOCAB_CONFIG_DIR}/**/*.yml --vocabListFileIgnore ${VOCAB_CONFIG_DIR}/bin/**/*.yml --outputDirectory ${TARGET_DIR}/Generated --force --clearOutputDirectory --noprompt --publish [ \"mavenLocal\", \"npmLocal\" ]"
else
    if [ "${NPM_OTP_VALUE}" != "NONE" ]
    then
        printf "\n${BLUE}Setting NPM OTP value to [${RED}${NPM_OTP_VALUE}${BLUE}].${NORMAL}\n"

        find ${TARGET_DIR} -type f \( -name '*.yml' -o -name '*.yaml' \) -not -path "*/bin/*" -not -path "*/Generated/*" -not -path "*/.github/*" -print0 | xargs -0 sed --in-place "s/ --otp=[0-9]\+/ --otp=${NPM_OTP_VALUE}/g"
    fi

    printf "\n${BLUE}Executing the Artifact Generator to re-generate and re-publish ${RED}(REMOTELY)${BLUE} artifacts from all YAML files found from [${SCRIPT_DIR}].${NORMAL}\n"
    run_command "node ${AG_DIR}/artifact-generator/index.js generate --vocabListFile ${VOCAB_CONFIG_DIR}/**/*.yml --vocabListFileIgnore ${VOCAB_CONFIG_DIR}/bin/**/*.yml --outputDirectory ${TARGET_DIR}/Generated --force --clearOutputDirectory--noprompt --publish [ \"nexus\", \"npmPublic\" ]"

    printf "\n\n\n EXIT NOW!"
fi
