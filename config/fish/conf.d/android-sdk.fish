set -q ANDROID_HOME
or export ANDROID_HOME="$HOME/Android/Sdk"
for dir in tools platform-tools build-tools cmdline-tools
    test -d $ANDROID_HOME/$dir
    and fish_add_path -gp $ANDROID_HOME/$dir
end
