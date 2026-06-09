function clkm --wraps='set -lx CLAUDE_CONFIG_DIR=$HOME/.claude-km; and claude' --description 'claude code, logged in for kaimate'
  set -lx CLAUDE_CONFIG_DIR $HOME/.claude-km
  and claude $argv
end
