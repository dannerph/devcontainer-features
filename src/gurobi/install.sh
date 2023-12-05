#!/bin/bash

GRB_VERSION=${VERSION:-"11.0.0"}
GRB_SHORT_VERSION=${GRB_VERSION:0:4}

USERNAME=${USERNAME:-${_REMOTE_USER:-"automatic"}}
UPDATE_RC="${UPDATE_RC:-"true"}"
GUROBI_DIR="/opt/gurobi"

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Ensure that login shells get the correct path if the user updated the PATH using ENV.
rm -f /etc/profile.d/00-restore-env.sh
echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh

# Determine the appropriate non-root user
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u "${CURRENT_USER}" >/dev/null 2>&1; then
            USERNAME=${CURRENT_USER}
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u "${USERNAME}" >/dev/null 2>&1; then
    USERNAME=root
fi

updaterc() {
    if [ "${UPDATE_RC}" = "true" ]; then
        echo "Updating /etc/bash.bashrc and /etc/zsh/zshrc..."
        if [[ "$(cat /etc/bash.bashrc)" != *"$1"* ]]; then
            echo -e "$1" >> /etc/bash.bashrc
        fi
        if [ -f "/etc/zsh/zshrc" ] && [[ "$(cat /etc/zsh/zshrc)" != *"$1"* ]]; then
            echo -e "$1" >> /etc/zsh/zshrc
        fi
    fi
}

cleanup_apt() {
    # shellcheck source=/dev/null
    source /etc/os-release
    if [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]; then
        rm -rf /var/lib/apt/lists/*
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            echo "Running apt-get update..."
            apt-get update -y
        fi
        apt-get -y install --no-install-recommends "$@"
    fi
}

export DEBIAN_FRONTEND=noninteractive

cleanup_apt
check_packages curl ca-certificates

echo "Download and extract..."
mkdir ${GUROBI_DIR}
curl -L https://packages.gurobi.com/${GRB_SHORT_VERSION}/gurobi${GRB_VERSION}_linux64.tar.gz | tar xz -C ${GUROBI_DIR} --strip-components=1

chown -R "${USERNAME}" "${GUROBI_DIR}"
chmod -R g+r+w "${GUROBI_DIR}"

# Clean up
cleanup_apt

GUROBI_HOME="/opt/gurobi/linux64"
PATH="${GUROBI_HOME}/bin:${PATH}"
LD_LIBRARY_PATH="${GUROBI_HOME}/lib:$LD_LIBRARY_PATH"

updaterc "export GUROBI_HOME=\"${GUROBI_HOME}\""
updaterc "export PATH=\${GUROBI_HOME}/bin:\${PATH}"
updaterc "export LD_LIBRARY_PATH=\"\${GUROBI_HOME}/lib:\${LD_LIBRARY_PATH}\""

echo "Done!"
