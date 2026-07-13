#!/bin/bash
echo "$1" >> /tmp/waybar-ws.log
hyprctl eval "hl.dispatch(hl.dsp.focus({ workspace = \"$1\" }))"
