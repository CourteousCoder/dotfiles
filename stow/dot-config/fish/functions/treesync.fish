function treesync --description 'merges the directory structure under the first argument into the directory structures under each remaining argument, and without copying files'
    # Normalize args into distinct realpaths
    true
    and set -l argv (path resolve $argv | uniq -u)
    and set -l source_dir (realpath $argv[1])
    and set -l dest_dirs $argv[2..] 
    echo $argv
    and mkdir -p $argv
    or begin
        printf 'ERROR: source_dir must exist and dest_dirs must either be directories or non-existent'
        return 1
    end

    pushd $source_dir
    or return 1
    for dest in $dest_dirs
        find . -mindepth 2 -type d -exec mkdir -p $dest/'{}' ';'
        or continue
        echo $source_dir to $dest
    end
    popd
end
