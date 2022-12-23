# Bumps marketing version

set -oe pipefail

PLUGIN_XCPROJ_DIR="./AVPlugin"
DEMO_XCPROJ_DIR="./AVPlayerDemo"

echo "Setting marketing version to $1"

(cd $PLUGIN_XCPROJ_DIR && xcrun agvtool new-marketing-version $1)
(cd $DEMO_XCPROJ_DIR && xcrun agvtool new-marketing-version $1)