#!/bin/bash
#
# CHIRP installation script
# https://chirpmyradio.com/projects/chirp/wiki/ChirpOnLinux

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}=== $* ===${NC}\n"
}

print_info() {
    echo -e "${GREEN}[✓]${NC} $*"
}

print_error() {
    echo -e "${RED}[✗]${NC} $*"
    exit 1
}

# Detect OS
print_header "Detecting Linux Distribution"

if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
    print_info "Detected: $PRETTY_NAME"
else
    print_error "Cannot detect Linux distribution"
fi

# Install dependencies based on distro
print_header "Installing System Dependencies"

case "$OS" in
    debian|ubuntu|linuxmint)
        print_info "Installing Debian/Ubuntu packages..."
        sudo apt-get update
        sudo apt-get install -y python3-wxgtk4.0 pipx
        ;;
    fedora|rhel|centos)
        print_info "Installing Fedora/RHEL packages..."
        sudo dnf install -y python3-wxpython4 pipx
        ;;
    *)
        print_error "Unsupported distribution: $OS. Please install python3-wxgtk4.0 and pipx manually."
        ;;
esac

# Check if wheel file exists locally
print_header "Preparing CHIRP Installation"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WHEEL_FILE="$(find "$SCRIPT_DIR/chirp/packages" -maxdepth 1 -name 'chirp-*.whl' | sort | tail -n 1)"

if [[ -n "$WHEEL_FILE" && -f "$WHEEL_FILE" ]]; then
    print_info "Found local wheel file: $WHEEL_FILE"
else
    print_error "Wheel file not found in $SCRIPT_DIR/chirp/packages/"
fi

# Install CHIRP using pipx
print_header "Installing CHIRP"

print_info "Installing CHIRP using pipx..."
pipx install --system-site-packages "$WHEEL_FILE"

# Verify installation
print_header "Verifying Installation"

if command -v chirp &>/dev/null; then
    print_info "CHIRP installed successfully!"
    echo "Location: $(which chirp)"
else
    print_error "CHIRP installation failed!"
fi

# Show usage
print_header "Quick Start"

echo "Launch CHIRP GUI:"
echo "  chirp"
echo ""
echo "Download from radio:"
echo "  chirp --action download --file myradio.img /dev/ttyUSB0"
echo ""
echo "Upload to radio:"
echo "  chirp --action upload --file myradio.img /dev/ttyUSB0"
echo ""
echo "List supported radios:"
echo "  chirp --list-radios | less"
echo ""

print_info "Installation complete! Run 'chirp' to start."
