# Gurobi Development Container Feature

Installs the Gurobi solver into a [development container](https://containers.dev/).

## Example Usage

```json
"features": {
    "ghcr.io/dannerph/devcontainer-features/gurobi:1": {}
}
```

## Options

You can select a specific Gurobi version. For example, the following installs version 11.0.0:

```json
"features": {
    "ghcr.io/dannerph/devcontainer-features/gurobi:1": {
        "version": "11.0.0"
    }
}
```

## License File

The Gurobi license file can be mounted using the default mounting method of dev containers (example below for Linux host)

```json
"mounts": [
    "source=${localEnv:HOME}/gurobi.lic,target=/home/vscode/gurobi.lic,type=bind,consistency=cached"
]
```
