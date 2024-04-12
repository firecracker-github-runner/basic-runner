#!/usr/bin/env bash

set -euo pipefail

nix-env -iA cachix -f https://cachix.org/api/v1/install
cachix use devenv

# see: https://devenv.sh/getting-started
nix-env -iA devenv -f https://github.com/NixOS/nixpkgs/tarball/nixpkgs-unstable
