function nano --wraps=nvim --description 'alias nano=command -v nvim > /dev/null && nvim; command -v nvim > /dev/null  || command nano'
  command -v nvim > /dev/null && nvim; command -v nvim > /dev/null  || command nano $argv
        
end
