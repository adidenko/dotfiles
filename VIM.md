# VIM

## Puppet functions

[Vim plugin file](.vim/plugin/puppet_helpers.vim) - you can download it into
your `.vim/plugin` directory:
```
mkdir -p $HOME/.vim/plugin
wget -O $HOME/.vim/plugin/puppet_helpers.vim \
  https://raw.githubusercontent.com/adidenko/dotfiles/master/.vim/plugin/puppet_helpers.vim
```

* **Parameters description** In `VISUAL` mode select class parameters,
press `CTRL+P`. Then in `INSERT` mode you can paste parameters description
template by pressing `CTRL+r` and then `p`.

  [ASCIINEMA DEMO](https://asciinema.org/a/k5ZjjpkRcT7vDmGqmnR6ZFEO7)

* **Parameters validation** In `VISUAL` mode select class parameters (you can
include class name in selection if you want to use Qualified Variable Names),
press `CTRL+O`. Then in `INSERT` mode you can paste parameters validation
functions pressing `CTRL+r` and then  `o`.

  [ASCIINEMA DEMO](https://asciinema.org/a/GmS7qDXN8nYShjSPsi9atPCP4)
