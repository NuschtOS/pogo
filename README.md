# Pogo

Pogo is an opinionated module for NixOS building on top of [disko](http://github.com/nix-community/disko/).
Right now it offers a high level abstraction for ZFS including good defaults and a starter dataset layout.

## Design

This module is designed to be used to generate the `fileSystems` NixOS option and preserve compatibility with previously formatted systems on updates.
To ensure that there is a `stateVersion` option and every change that could cause a breakage for an existing system and render it unbootable must bump that version.
We use snapshot testing to ensure that compatibility. See [Checks](#checks).
With ever bump of `stateVersion` a new `synthetic-state-version-X.X` test must be created which tests that exact change.
We also have tests for our machines to make sure they do not break on updates. Those might be updated in the future.
If there are regressions, a specific test for those should be created to make sure we don't create the same bug twice.

## Checks

To run the snapshot tests open a nix dev shell with `nix develop` and run the following:

```
namaka check && namaka review
```

## Name

The name is not a silly joke of *Disco Pogo* from *Die Atzen*.

## Contact

For bugs and issues please open an issue in this repository.

If you want to chat about things or have ideas, feel free to join the [Matrix chat](https://matrix.to/#/#nuschtos:c3d2.de).
