
function check-membership -d 'Print a subset of the given groups, of each of which ANY of the given users is a member. If no users list is given, defautls to current user'
    argparse --name='check-membersip' -N 1 'h/help' 'u/users=+' -- $argv

    if set -ql _flag_help
        echo (
            echo 'check-membership'
            echo
            echo 'Print the subset GROUPS where each group has at least one of USERS a membe'
            echo 'If no users are given with -u, USERS defaults to just the current user'
            echo
            echo "Usage: $_argparse_cmd [-h | --help] [ -u | --users=USERS...] GROUPS..."
        ) >&2
        return 1
    end

    set -lq _flag_users[1]
    and set -l user_names $_flag_users
    or set -l user_names $USER

    set -l group_names (string join '|' $argv)
    id -Gn $user_names | string split ' ' | grep -E $group_names | sort -u
end
