#!/usr/bin/env fish

function read_confirm
    set -l confirmation_text $argv

    test -n $argv;
    or set -l 'confirmation_text Do you want to continue?'

    while true
        read -l -P "$confirmation_text [y/N]" confirm

        switch $confirm
        case Y y
            return 0
        case '' N n
            return 1
        end
    end
end

