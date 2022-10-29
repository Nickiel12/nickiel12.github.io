with ( import <nixpkgs> {});
let
  env = bundlerEnv {
    name = "github-pages";
    inherit ruby;
    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset = ./gemset.nix;
  };
in 
  stdenv.mkDerivation {
    name = "github-pages";
    buildInputs = [ env bundler ruby ];
  }
