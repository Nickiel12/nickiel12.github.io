---
layout: post
title: "Nix and Rust Development"
author: "Nickiel"
date: 2022-10-29
tags: nix nixos rust rust-analyzer
categories: nixos
---
#### Note
This article covers three possible fixes - global NixOs configurations, and `nix-shell` configs, and the newer `nix develop` configuration (a blog post coming soon about that soon).

### Overview
For those of us who use NixOs, the Linux distribution, the draw is simple, repeatable, straightforward OS configuration. Simply clone your configuration, run `nixos-install`, and you are right at home - no fiddling around with .config files hoping you remember everything (or hacky scripts to copy all your files for you, as I am guilty of). 

This is great for almost any program. Did the latest version of the battery manager break your power button? (true story) No problem, simply rollback the file version in your `.nix` file.

But this power comes at a cost; what happens when two pieces of software meant to manage software versions try to manage the same package?

Enter `rustup` vs `NixOs`. If you are here, you probably already know that Rust (the programming language, not the game) comes with `rustup` to manage toolchain versions - `rustc` to compile, the amazing `cargo` utility to manage packages, `rustfmt` for standardized formatting, etc. Very similarly to the way NixOs handles program files. 

While NixOs can install `cargo`/`rustc` and they will coexist peacefully, it is more of an fragile armistice than a happy working relationship.

This means you certainly could install rust and `cargo` globally and compile your projects to your hearts content without *too* much hassle, once you try and use rust-analyzer, you find things start to break down.

Rust-analyzer, the de-facto rust language server used in IDEs from VSCode to VIM, requires `rust-src` to be installed - the rust source code it checks your code against. However, this package isn't installed alongside `rustc` and `cargo` when NixOs installs it, in fact, much of the rust toolchain isn't available in the default NixOs packages.

Enter Nix's answer to problems like these - overlays. 

While you do not need to know what an overlay is to use these, it is helpful to understand how they work [read more here](www.something.com).

### NixOs
If you are reading this section, you already have your configuration files set up, and are almost definetly familiar with overlays. [The Github README](https://github.com/oxalica/rust-overlay) has more in-depth instructions, but I'll past the relevant information here:
```Nix
# <configuration.nix>, <flake.nix> or equivalent
inputs = {
	nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
	rust-overlay.url = "github:oxalica/rust-overlay";
}

outputs = { nixpkgs, rust-overlay, ... }: {
	nixosConfigurations = {
		hostname ... {
			system ...
			modules = [
				...
				({ pkgs, ... }: {
					nixpkgs.overlays = [ rust-overlay.overlays.default ];
					environment.systemPackages = [ pkgs.rust-bin.stable.latest.default ]; # install the latest stable rust default toolchain
				})
			];
		};
	};
}
```

### Nix Develop
For those of you familiar with `nix-shell`, `nix develop` won't be that new to you. There is an ongoing effort to combine `nix-env`, `nix-shell` and `nix-build`, and other `nix-...` commands into one singular `nix` command - which leads to this alternate configuration.

While I am not familiar with `nix develop` yet, I will soon be digging more into it and replacing my `shell.nix` files with `nix develop` compatible versions. 

Luckily for ~~me~~ us, there is an example `nix develop` configuration file provided in the README for the rust-overlay project! While I may not know where this configuration is *actually* supposed to go... It is good to have. (Note to future self: Update this section when I understand)
```Nix
# www.github.com/oxalica/rust-overlay/README.md
{
	description = "a devShell example";

	inputs = {
		nixpks.url       = "github:NixOS/nixpkgs/nixos-unstable";
		rust-overlay.url = "github:oxalica/rust-overlay";
		flake-utils.url  = "github:numtide/flake-utils";
	};

	outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
		flake-utils.lib.eachDefaultSystem (system:
			let
				overlays = [ (import rust-overlay) ]; 
				pkgs = import nixpkgs {
					inherit system overlays;
				};
			in
			with pkgs;
			{
				devShell.default = mkShell {
					buildInputs = [
						openssl
						pkg-config
						exa
						fd
						rust-bin.beta.latest.default
					];
					
					shellHook = ``
						alias ls=exa
						alias find=fd
					``;
				};
			}
		);
}
```
Please let me know if there was a typo, because I typed this out, instead of copy-and-pasting this and probably made a typo somewhere in that code block.

### Nix-shell
For those of you who already know about `nix-shell`, you can skip this section and go to the solution below. For the rest of us who installed NixOs without knowing about `nix` and `nix-shell`, read on. 

**Note: Nix-shell is being replaced with `nix develop` `nix shell` and `nix run`.**

I won't claim to be anything more than a dabbler with `nix-shell`, as I haven't started any projects with `nix-shell` in my tool belt yet, but I have retro-fitted several projects to work with `nix-shell` with minimal issues (once I got a basic `shell.nix` file working anyways).

Nix is a shell environment much like `bash` or `zsh` and others, that can be installed on Windows, Mac, and Linux as a standalone application and project dependency manager. 
It comes with a tool `nix-shell` that, when it is run, looks in the directory it was run in for a `default.nix` or `shell.nix` file that defines what should be available in the shell session, and installs it all for that shell environment.

This means you can define a `shell.nix` on one machine with the exact packages and compiler versions, copy it to another computer, and have the exact same environment for your project - no hassle or forgetting packages involved! I don't know about you, but that sounds pretty sweet to me! One file, and you can forget about that arcane list of python packages you installed globally - and no more polluting your global namespace either! (Yes, this is basically a python virtual environment, but with less hassle) Everything for the `nix-shell` is kept separate from the rest of the operating system, and is only used for that shell environment. 

But enough of a sales pitch. Here is what a minimal rust `shell.nix` should look like.

In the root of your project, create a file and put this inside of it:
```Nix
# <shell.nix>
{ pkgs ? import <nixpkgs> {}}:
 
 let
   rust_overlay = import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz");
   pkgs = import <nixpkgs> { overlays = [ rust_overlay ]; };
   ruststable = (pkgs.rust-bin.stable.default);
 in
 pkgs.mkShell {
   buildInputs = with pkgs; [
     ruststable # tell nix-shell to install our overlayed rust version defined above
   ];
 }
```
Now, whenever you want to work on your project, `cd` to the root, and run `nix-shell` to start the shell environment. The first run (and any run after a manual NixOs garbage collector run) will download and install any packages defined in the `shell.nix` file. 

Now when you open your IDE on this project from the `nix-shell`, rust-analyzer and `coc-rust-analyzer` will be able to find `rust-src` and will prompt you to download the latest version and work like normal.

#### TL:DR Example `shell.nix`
Here is the `shell.nix` template that I use for my rust projects. I simply copy this and edit it as required for each project.
```Nix
# `shell.nix` placed at the root of the project
# and activated with `nix-shell`
{ pkgs ? import <nixpkgs> {}}:
 
 let
   rust_overlay = import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz");
   pkgs = import <nixpkgs> { overlays = [ rust_overlay ]; };
   ruststable = (pkgs.latest.rustChannels.stable.default.override {
       extensions = [
         "rust-src" # required for rust-analyzer to work 
         "rustfmt"  # allows you to run rustfmt in your nix-shell
         "clippy"   # for more see https://doc.rust-lang.org/book/appendix-04-useful-development-tools.html section on Clippy
       ];
     });
 in
 pkgs.mkShell {
   buildInputs = with pkgs; [ # you can also add any packages found in the official NixOs packages here to be included in the shell environment
   
     ruststable # install the overlay package we defined above
   ];
 
   RUST_BACKTRACE = 1; # Set this environment variable in the nix-shell
 }
```
### Options
Taken from the Github page, you can select your toolchain like so:
```Nix
	rust-bin.stable.latest.default # Stable rust, default profile. If not sure, always choose this.
	rust-bin.beta.latest.default   # Wanna test beta compiler.
	rust-bin.stable.latest.minimal # I don't need anything other than rustc, cargo, rust-std. Bye rustfmt, clippy, etc.
	rust-bin.beta.latest.minimal 
```

For more information on nightlys, selecting specific toolchain components, specific version of rust, specific `rustc` git revisions and more, [See the project's readme](https://github.com/oxalica/rust-overlay).

### In closing
With the power of overlays, even package manager conflicts can be resolved with nothing more than a few lines of code. Also, try `nix-shell` if you haven't for the true Nix experience. 

Until next time.

