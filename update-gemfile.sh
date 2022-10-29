#!/usr/bin/env bash

nix-shell -p bundler -p bundix --run 'bundler update; bundler lock; bundler package --no-install --path vender; bundix; rm -rf vender'

echo "updated"
