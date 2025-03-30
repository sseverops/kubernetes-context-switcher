#!/usr/bin/env zsh

set -e

BIN_DIR="$HOME/bin"
ZSHRC="$HOME/.zshrc"

brew install fzf

mkdir -p $BIN_DIR
cat << 'EOF' > $BIN_DIR/kcuc
#!/usr/bin/env zsh
if ! command -v fzf &> /dev/null; then
    echo "fzf is not installed. Install it using 'brew install fzf' (macOS) or 'apt install fzf' (Linux)."
    exit 1
fi
CONTEXTS=$(kubectl config get-contexts --output=name)
if [ -z "$CONTEXTS" ]; then
    echo "No available Kubernetes contexts."
    exit 1
fi
SELECTED_CONTEXT=$(echo "$CONTEXTS" | fzf --prompt="Select a Kubernetes context: " --height=10 --border --reverse)
if [ -z "$SELECTED_CONTEXT" ]; then
    echo "Selection canceled."
    exit 1
fi
kubectl config use-context "$SELECTED_CONTEXT"
EOF
chmod u+x $BIN_DIR/kcuc

if ! grep -q "export PATH=\"$BIN_DIR:\$PATH\"" "$ZSHRC"; then
    echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$ZSHRC"
    echo "→ Added $BIN_DIR to PATH in ~/.zshrc"
    echo "→ Run this to apply changes:"
    echo "  source ~/.zshrc"
else
    echo "✓ $BIN_DIR is already in PATH (~/.zshrc)"
fi
