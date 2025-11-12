# Gurobi

Install the rust-based tex-fmt LaTex formatter. Only works for Debian based systems.

## Example Usage

```json
"features": {
    "ghcr.io/dannerph/devcontainer-features/tex-fmt:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Select the tex-fmt version | string | v0.5.6 |

## Example

You can select a specific tex-fmt version from <https://github.com/WGUNDERWOOD/tex-fmt/releases>. For example, the following installs version v0.5.6:

```json
"features": {
    "ghcr.io/dannerph/devcontainer-features/tex-fmt:1": {
        "version": "v0.5.6"
    }
}
```
