# rootless-nix-arc-runner

A self-hosted runner with nix pre-installed (daemon-less) and configured to run rootless.

NOTE:
- Assumes `/nix/store` is mounted as an `emptyDir` at runtime. `/nix/store_base` which can be `cp`'d over as needed.
- Uses a `sudo` shim to support some nix actions that use it to interact with `/nix/store`. As the store is mounted as a volume, the runner can freely write sans `sudo`.
