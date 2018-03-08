#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/util.sh

usage ()
{
cat << EOF

Usage:
   $0 [OPTIONS]

WebRTC automated build script.

OPTIONS:
   -o OUTDIR      Output directory. Default is 'out'
   -b BRANCH      Latest revision on git branch. Overrides -r. Common branch names are 'branch-heads/nn', where 'nn' is the release number.
   -r REVISION    Git SHA revision. Default is latest revision.
   -t TARGET OS   The target os for cross-compilation. Default is the host OS such as 'linux', 'mac', 'win'. Other values can be 'android', 'ios'.
   -c TARGET CPU  The target cpu for cross-compilation. Default is 'x64'. Other values can be 'x86', 'arm64', 'arm'.
   -l BLACKLIST   List *.o objects to exclude from the static library.
   -e ENABLE_RTTI Compile WebRTC with RTII enabled. Default is '1'.
   -x             Express build mode. Skip repo sync and dependency checks, just build, compile and package.
   -d             Debug mode. Print all executed commands.
   -h             Show this message
EOF
}

while getopts :o:b:r:t:c:l:e:xd OPTION; do
  case $OPTION in
  o) OUTDIR=$OPTARG ;;
  b) BRANCH=$OPTARG ;;
  r) REVISION=$OPTARG ;;
  t) TARGET_OS=$OPTARG ;;
  c) TARGET_CPU=$OPTARG ;;
  l) BLACKLIST=$OPTARG ;;
  e) ENABLE_RTTI=OPTARG ;;
  x) BUILD_ONLY=1 ;;
  d) DEBUG=1 ;;
  ?) usage; exit 1 ;;
  esac
done

OUTDIR=${OUTDIR:-out}
BRANCH=${BRANCH:-}
BLACKLIST=${BLACKLIST:-}
ENABLE_RTTI=${ENABLE_RTTI:-1}
ENABLE_ITERATOR_DEBUGGING=0
ENABLE_CLANG=1
ENABLE_STATIC_LIBS=1
BUILD_ONLY=${BUILD_ONLY:-0}
DEBUG=${DEBUG:-0}
PROJECT_NAME=webrtc
COMBINE_LIBRARIES=${COMBINE_LIBRARIES:-0}
REPO_URL="https://chromium.googlesource.com/external/webrtc"
DEPOT_TOOLS_URL="https://chromium.googlesource.com/chromium/tools/depot_tools.git"
DEPOT_TOOLS_DIR=$DIR/depot_tools
TOOLS_DIR=$DIR/tools
PATH=$DEPOT_TOOLS_DIR:$DEPOT_TOOLS_DIR/python276_bin:$PATH

[ "$DEBUG" = 1 ] && set -x

REVISION_NUMBER=$(revision-number $REPO_URL $REVISION)

# label is <projectname>-<rev-number>-<short-rev-sha>-<target-os>-<target-cpu>
LABEL=$PROJECT_NAME-$REVISION_NUMBER-$(short-rev $REVISION)-$TARGET_OS-$TARGET_CPU
echo "Packaging WebRTC: $LABEL"
package $PLATFORM $OUTDIR $LABEL $DIR/resource
manifest $PLATFORM $OUTDIR $LABEL

echo Build successful
