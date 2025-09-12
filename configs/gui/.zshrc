#!/usr/bin/zsh

DEBUG_FILE=/home/gui/.debug

# setup a fake monitor
if [ -e "$DEBUG_FILE" ]; then
    export WLR_BACKENDS=headless
    export WLR_HEADLESS_OUTPUTS=1
    export WLR_HEADLESS_WIDTH=1920
    export WLR_HEADLESS_HEIGHT=1080
fi