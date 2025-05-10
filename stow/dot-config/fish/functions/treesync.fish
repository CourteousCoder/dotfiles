function treesync --description 'merges the directory structure under the first argument into the directory structures under each remaining argument, and without copying files'
    if not set -q argv[2]
        echo "need at least 2 arguments"
        return 1
    end
    set source_dir (path resolve $argv[1])
    set dest_dirs (path resolve $argv[2..])

    pushd $source_dir
    or return= 1
    for dest in $dest_dirs 
        find . -mindepth 2 -type d -exec mkdir -p -- $dest/{} \;
        or continue
        echo $source_dir to $dest
    end
    popd
end
