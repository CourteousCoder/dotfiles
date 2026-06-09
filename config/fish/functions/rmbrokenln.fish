function rmbrokenln --description 'Find and remove all broken symlinks in the given directory tree'
	find $argv -type l -exec test ! -e {} \; -print  -delete
end
