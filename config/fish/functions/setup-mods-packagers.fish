function setup-mods-packagers --wraps='sudo chgrp -Rch --preserve-root packagers /usr/local/src/*; and sudo chmod -Rc --preserve-root g+rw /usr/local/src/*' --description 'alias setup-mods-packagers sudo chgrp -Rch --preserve-root packagers /usr/local/src/*; and sudo chmod -Rc --preserve-root g+rw /usr/local/src/*'
  sudo chgrp -Rch --preserve-root packagers /usr/local/src/*; and sudo chmod -Rc --preserve-root g+rw /usr/local/src/* $argv
        
end
