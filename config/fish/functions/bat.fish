function bat --wraps=batcat --description 'alias bat=batcat'
  if command -q batcat
    batcat $argv
  else
    command bat $argv
  end
end
