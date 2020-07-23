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
# Default directory to target is a sibling directory of where this script is.
TARGET_DIR="${PWD}"
INCLUDE_MASK="*.{yml,yaml}"
EXCLUDE_DIR="bin,Generated,node_modules,.github"

helpFunction() {
    printf "${BLUE}Usage: $0 [ -t <TargetDirectory> ] [ -a <LAG versions> | -b <Java-LVT versions> | -c <JavaScript_LVT versions> | -d <Generated Java versions> | -e <Generated JavaScript versions> ]\n"
    printf "Displays version numbers being used across LIT Artifact Generator configuration files.${NORMAL}\n"
    printf "${RED}NOTE: Also displays version numbers from commented-out entries, which will be prefixed with a hash '#'.${NORMAL}\n\n"
    printf "${BLUE}Options:${NORMAL}\n"
    printf "\t-t ${YELLOW}Optional: ${BLUE}Target directory (default is: [${TARGET_DIR}])${NORMAL}\n"
    printf "\t-a ${BLUE}LIT Artifact Generator versions${NORMAL}\n"
    printf "\t-b ${BLUE}Solid Common Vocab Java versions${NORMAL}\n"
    printf "\t-c ${BLUE}Solid Common Vocab JavaScript versions${NORMAL}\n"
    printf "\t-d ${BLUE}Generated Java JAR versions${NORMAL}\n"
    printf "\t-e ${BLUE}Generated JavaScript NPM versions${NORMAL}\n\n"
}

while getopts ":t:abcde" opt
do
    case "$opt" in
      t ) TARGET_DIR="$OPTARG" ;;
      a ) litArtifactGenerator=true ;;
      b ) litVocabTermJava=true ;;
      c ) litVocabTermJavaScript=true ;;
      d ) artifactJava=true ;;
      e ) artifactJavaScript=true ;;
      ? ) helpFunction ;; # Print help in case parameter is non-existent
    esac
done

if [ "${1:-}" == "?" ] || [ "${1:-}" == "-?" ] || [ "${1:-}" == "-h" ] || [ "${1:-}" == "--help" ]
then
    helpFunction
    exit 1 # Exit script after printing help.
fi

# Print help in case parameters are empty, but display everything.
if [ "${litArtifactGenerator:-}" == "" ] \
  && [ "${litVocabTermJava:-}" == "" ] \
  && [ "${litVocabTermJavaScript:-}" == "" ] \
  && [ "${artifactJava:-}" == "" ] \
  && [ "${artifactJavaScript:-}" == "" ]
then
    echo "${RED}No specific options - displaying all!${NORMAL}";
    helpFunction

    litArtifactGenerator=true;
    litVocabTermJava=true;
    artifactJava=true;
    litVocabTermJavaScript=true;
    artifactJavaScript=true;
fi

printf "${BLUE}Displaying versions from YAML files found within target directory: [${TARGET_DIR}]${NORMAL}\n\n"

if [ "${litArtifactGenerator:-}" ]
then
    # LIT Artifact Generator.
    # Alternative is to use 'find' first, but grep can handle what we need.
    #  command="find . -type f \( -name '*.yml' -o -name '*.yaml' \) -not -path \"*/Generated/*\" -exec grep \"artifactGeneratorVersion:\" {} +"
    command="grep -r \"artifactGeneratorVersion:\" ${TARGET_DIR} --include=${INCLUDE_MASK} --exclude-dir={${EXCLUDE_DIR}}"
    printf "${RED}a) LIT Artifact Generator versions:${NORMAL}\n"
    echo $command | bash | sed 's/\s*artifactGeneratorVersion: //' | column -s ':' -t
    echo ""
fi

if [ "${litVocabTermJava:-}" ]
then
    # Java Solid Common Vocab versions.
    command="grep -r \"solidCommonVocabVersion:\s*[0-9]\" ${TARGET_DIR} --include=${INCLUDE_MASK} --exclude-dir={${EXCLUDE_DIR}}"
    printf "${RED}b) Java Solid Common Vocab versions:${NORMAL}\n"
    echo $command | bash | sed 's/\s*solidCommonVocabVersion: //' | column -s ':' -t
    echo ""
fi

if [ "${litVocabTermJavaScript:-}" ]
then
    # JavaScript Solid Common Vocab versions.
    command="grep -r \"solidCommonVocabVersion:\s*\\\"\^\" ${TARGET_DIR} --include=${INCLUDE_MASK} --exclude-dir={${EXCLUDE_DIR}}"
    printf "${RED}c) JavaScript Solid Common Vocab versions:${NORMAL}\n"
    echo $command | bash | sed 's/\s*solidCommonVocabVersion: //' | column -s ':' -t
    echo ""
fi

if [ "${artifactJava:-}" ]
then
    # Java generated artifact versions.
    command="grep -r \"artifactVersion:\s*[0-9]\" ${TARGET_DIR} --include=${INCLUDE_MASK} --exclude-dir={${EXCLUDE_DIR}}"
    printf "${RED}d) Generated Java JAR versions:${NORMAL}\n"
    echo $command | bash | sed 's/\s*artifactVersion: //' | column -s ':' -t
    echo ""
fi

if [ "${artifactJavaScript:-}" ]
then
    # JavaScript generated artifact versions.
    command="grep -r \"artifactVersion:\s*\\\"\" ${TARGET_DIR} --include=${INCLUDE_MASK} --exclude-dir={${EXCLUDE_DIR}}"
    printf "${RED}e) Generated JavaScript NPM versions:${NORMAL}\n"
    echo $command | bash | sed 's/\s*artifactVersion: //' | column -s ':' -t
    echo ""
fi
