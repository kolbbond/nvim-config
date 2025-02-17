## NEOVIM CONFIG

We assume you already have neovim but make sure have an up to date version 
by either building yourself from source [neovim](https://github.com/neovim/neovim.git)
or getting one of the nightly appimages.

To basic install run 

```shell
git clone https://github.com/kolbbond/nvim-config.git ~/.config/nvim
cd ~/.config/nvim
chmod +x init.sh
./init.sh
```
This will clone this repo and install packer.

then run 
` :PackerSync `

to install all plugins

It is recommended to also alias vim to nvim in your bashrc.

`alias vim='nvim'`

install ripgrep 
` pip install ripgrep `

### Additional LSP support
We rely on Mason to manage our LSPs.
Some of them rely on NPM (matlab and bash)

run `:Mason` to open the nice gui to install and manage LSPs

### Useful features
We have many remaps to gain efficiency. These rely on the "<leader>" key which is set to SPACEBAR.

`<leader>pv` "Project viewer" open netrw window to move around directory.

`<leader>pf` "Project file" project file search, helpful to find a specific file.

`<leader>ps` "Project search" project search, ripgrep a phrase, useful for mass search and replace.

`<leader>sh` "clang remap, switch between source and header files in a c project. requires that the lsp  
can find include and src directory. Since we rely on cmake we suggest that you set
`set(CMAKE_EXPORT_COMPILE_COMMANDS ON)` in your CMakeLists.txt to help clangd.

`<leader>cfp` current file path

### REPLS
`:MatlabLaunchServer` launch the matlab repl
`<leader>mf` run entire matlab file
`<leader>rr` run matlab section (cell)
`CTRL+L` run single matlab line

We have basic python repl support
`:IronRepl` launch iron repl (for python)
`<leader>sl` send python line to interpreter





