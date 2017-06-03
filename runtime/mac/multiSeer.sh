
#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

$DIR/SEER_desktop.app/Contents/MacOS/SEER_desktop -workdir $DIR/../../  #-load-framework -disable-write-debug-log -scale 1 #-position 1199,-1 -console  -topmost -disable-console
#-resolution 1136x640
#-landscape
