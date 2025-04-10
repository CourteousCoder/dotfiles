function unhide-dots --description 'Unhide dotfiles by transforming "." into "dot-" recursively for each relative path'
    set -l _prefix "dot-"
    sed -re "s#\.(([^\./]*\.*)*[^\./])#$_prefix\1#g"
end
