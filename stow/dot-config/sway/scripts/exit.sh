#!/usr/bin/env bash

if [ ! $(pgrep -x "swaynag") ]; then

    window_color="333333"
    text_color="FFFFFF"
    edge="top"

    message_text="Do you really want to log out?"
    message_type="warning"

    button_action="swaymsg exit"
    button_text="Yes"
    button_color="901F90"
    button_border_size="0"
    button_padding="8"

    swaynag \
        --background            "$window_color" \
        --border                "$window_color" \
        --border-bottom         "$window_color" \
        --button-background     "$button_color" \
        --button-border-size    "$button_border_size" \
        --button-no-terminal    "$button_text"  "$button_action" \
        --button-padding        "$button_padding" \
        --button-text           "$text_color"\
        --edge                  "$edge" \
        --message               "$message_text" \
        --text                  "$text_color" \
        --type                  "$message_type" \
    ;
fi
