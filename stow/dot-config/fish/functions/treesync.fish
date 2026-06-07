function treesync --description 'merges the directory structure under the first argument into the directory structures under each remaining argument, and without copying files'
    # Normalize args into distinct realpaths
    true
    and set -l argv (path resolve $argv | uniq.awk)
    and set -l source_dir (realpath $argv[1]); or return 1
    and set -l dest_dirs $argv[2..] 

    test -d $source_dir
    and echo Creating destination directories: $dest_dir
    and mkdir -p $dest_dirs
    or begin
        printf 'ERROR: source_dir must exist and dest_dirs must either be directories or non-existent'
        return 1
    end
    
    pushd $source_dir
    and find . -mindepth 2 -type d -exec mkdir -p $dest_dirs/'{}' ';'
    and popd
end
