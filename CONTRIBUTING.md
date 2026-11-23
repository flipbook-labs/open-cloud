# Contributing

## Set up

Install the toolchain pinned in `rokit.toml` with [Rokit](https://github.com/rojo-rbx/rokit), then Lute's type definitions and the dependencies:

```sh
rokit install
lute setup
lute run install
```

`lute run install` vendors each dependency into a gitignored `.lpm/` folder. The shared agent skills land there too.

## Check your changes

```sh
lute run check
```

This runs the same checks as CI:

- `changewrite check --fix` validates the changelog entries and rewrites any written for an older version of Changewrite.
- `lute run lint` runs [CodeQuality](https://github.com/flipbook-labs/code-quality)'s shared lint rules and StyLua, and fails on any file that uses `.lua` instead of `.luau`.
- `lute run analyze` type-checks the code with luau-lsp. `.config.luau` sets strict mode for every file.
- `lute test` runs the specs in `tests/`, which send calls through each client with a fake transport.

## Regenerate the clients

Each package's `init.luau` and `types.luau` are generated, so change them by regenerating rather than by hand:

```sh
lute run update-spec
lute run generate
```

`update-spec` pins `spec/source.luau` to the newest creator-docs commit that changed Roblox's spec. `generate` downloads the spec at that commit and runs OpenApiLuau over it for every package listed in `.lute/generate.luau`, so the same pin always generates the same clients. The Update Spec workflow does both every week and opens a pull request when the clients change.

To add a service, add its folder and tag to `.lute/generate.luau`, give it a `pkg.luau` like the others, and add it to the root `pkg.luau`.

## Add a changelog entry

Each pull request adds one Luau file to `.changes/`. [`.changes/README.md`](.changes/README.md) lists its fields. At release time, Changewrite combines the entries into `CHANGELOG.md`.
