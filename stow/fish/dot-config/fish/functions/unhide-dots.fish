function unhide-dots --description Renames\ all\ hidden\ items\ directly\ under\ each\ of\ the\ given\ directories\ by\ replacing\ the\ \'.\'\ prefix\ with\ \'dot-\'
    # TODO: Add options cli  with argparse
    set -l _verbose 1
    set -l _prefix "dot-"
    set -l _dirs "$PWD"
    if  count $argv > /dev/null
        set -l _dirs $argv
    end

    for d in $_dirs
        for h in $d/.*
            if set -lq _verbose; and [ "$_verbose" -eq 1 ]
                echo mv $h ( string replace "$d/." "$d/$_prefix" $h )
            end
            mv $h ( string replace "$d/." "$d/$_prefix" $h )
        end
    end
end
