function ssh --description 'OpenSSH SSH client (remote login program) with a conservative $TERM value'
  switch $TERM
    case 'screen-*'
      set -lx TERM screen
      command ssh $argv
    case 'xterm-*'
      set -lx TERM xterm
      command ssh $argv
    case '*'
      command ssh $argv
  end
end
