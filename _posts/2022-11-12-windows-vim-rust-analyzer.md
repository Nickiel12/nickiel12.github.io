---
layout: post
title: "Vim on Windows with Rust"
author: "Nickiel"
date: 2022-11-12
tags: vim windows rust rust-analyzer
categories: windows
---
### Intro
Vim is a cult classic text editor, and is a staple on any Linux distro for many. But we can't always have Linux. Sometimes, through forces outside our control we are *forced* to use a windows machine. 

However! Not all is lost in these cases; You can still use Vim! You just need to manually install a few dependencies.

### Overview
In this article I will cover how to install and set up Vim on a windows machine and configure it for use with Rust development (`coc` and `rust-analyzer`).

### TL:DR
Install Vim, NodeJS, and vim-plug, then follow the same Vim configuration as Linux.

### Installation
Go ahead and head over to the [Vim download page](https://www.vim.org/download.php) and pick up the... "PC: MS-DOS and MS-Windows"... download. I suppose that just dates Vim for you. Really important to support those backports to MS-DOS. Oh, and run the installer. 

Next go to [NodeJS](https://nodejs.org/en/) and download either the "Current" or "LTS" version. I picked LTS because I won't be using NodeJS exept for Vim with CoC. Install this too, and make sure to select the "Add to PATH" option.

Now we are going to install Vim-Plug to handle our Vim plugins. Visit [the Github page](https://github.com/junegunn/vim-plug) and scroll down to the [Windows (Powershell)](https://github.com/junegunn/vim-plug#windows-powershell-1) installation instructions. 
**NOTE:** This doesn't always work, so if it doesn't do the following: Open Vim, and enter `:echo $HOME`. Now go to the printed directory, and create a directory called `vimfiles\` then inside of that one create `autoload\` and manually copy [the source file](https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim) into `plug.vim` into the autoload folder. You should end up with `$HOME\vimfiles\autoload\plug.vim`.

### Plugins
Now we are going to make the `.vimrc` file and define what plugins to install. 

If this isn't your first time using Vim, you probably already have `.vimrc` settings you want to bring with you. So do that. All the normal settings work, and if you already have a working `.vimrc` for Rust, you probably only needed to install the windows dependencies to get Vim just like you have it on your Linux machine.

Open Vim and enter:
```VIM
:echo $HOME
```
Go to this path, and you should find a `.viminfo` or `_viminfo` (or both) already there. In this `$HOME` directory, create a file called `.vimrc`. This is the settings file for vim, and normally lives at `~/.vimrc` on Linux machines.

Inside this file put the following:
```Vim
call plug#begin()

    Plug 'rust-lang/rust.vim'                       --Official rust syntax highlighting
    Plug 'neoclide/coc.nvim', {'branch': 'release'} --CoC   
    Plug 'fannheyward/coc-rust-analyzer'            --Coc rust-analyzer plugin

call plug#end()
```

Now when you open Vim again it should have a window that shows it downloading these plugins. 

Finally, just to make sure rust-analyzer is correctly installed, open Vim and enter:
```Vim
:CocInstall coc-rust-analyzer
```
And say yes to the instructions. You can run this command again if you mess it up like I did the first time.

If at any point it asks if you want to uninstall/install, just say yes.

### In closing
Vim has become my favorite editor, pushing aside my long held-dear VSCode, simply because of how comfortable and in control I feel when doing things in Vim. And I am quite happy to say that I can now feel that on windows too.

Until next time.

### Resources
- For information about configuring CoC (actually check this one out, there are lots of configuration options available) [CoC Github page](https://github.com/neoclide/coc.nvim/)
- [Official Rust syntax highlighting Github page](https://github.com/rust-lang/rust.vim)
- [Coc-Rust-Analyzer Github page](https://github.com/fannheyward/coc-rust-analyzer)

