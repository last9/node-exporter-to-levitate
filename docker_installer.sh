#!/bin/bash

set -e

# Function to fail loudly
fail_loudly() {
    echo "ERROR: $1 failed to install." >&2
    exit 1
}

# Install docker
echo
echo "=========================="
echo "STATUS: docker"
echo "=========================="
if [[ -f '/usr/bin/docker' ]]; then
    echo "STATUS: docker: installed"
else
    echo "STATUS: docker: installing"
    set -ex
    curl -fsSL https://get.docker.com/ | sh -x || fail_loudly "docker"
    command -v docker >/dev/null || fail_loudly "docker"
    set +ex
    sudo groupadd docker
    sudo usermod -aG docker "$USER"
    echo "Please log out and log back in to ensure your group membership is re-evaluated."
    echo "STATUS: docker: installed"
fi

# Install docker-compose
echo
echo "=========================="
echo "STATUS: docker-compose"
echo "=========================="
if [[ -f '/usr/local/bin/docker-compose' ]]; then
    echo "STATUS: docker-compose: installed"
else
    echo "STATUS: docker-compose: installing"
    set -ex
    LATEST_COMPOSE=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
    if [ -z "$LATEST_COMPOSE" ]; then
        echo "ERROR: Failed to fetch latest docker-compose version." >&2
        exit 1
    fi
    sudo curl -L \
        "https://github.com/docker/compose/releases/download/${LATEST_COMPOSE}/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose || fail_loudly "docker-compose"
    sudo chmod +x /usr/local/bin/docker-compose
    command -v docker-compose >/dev/null || fail_loudly "docker-compose"
    set +ex
    echo "STATUS: docker-compose: installed"
		echo "Please log out and log back in to ensure your group membership is re-evaluated."
fi
