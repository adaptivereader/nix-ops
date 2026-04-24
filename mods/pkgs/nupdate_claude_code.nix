# Update script for claude-code-latest package
# Checks npm registry for new versions and updates the nix derivation
{ pkgs, pog, ... }:
let
  curl = "${pkgs.curl}/bin/curl";
  jq = "${pkgs.jq}/bin/jq";
  sed = "${pkgs.gnused}/bin/sed";
  nix-prefetch-url = "${pkgs.nix}/bin/nix-prefetch-url";
in
pog {
  name = "nupdate_claude_code";
  description = "Check and update claude-code-latest to the latest npm version";
  script = helpers: with helpers; ''
    NPM_REGISTRY_URL="https://registry.npmjs.org"
    PACKAGE_NAME="@anthropic-ai/claude-code"
    PACKAGE_NIX="mods/pkgs/claude-code-latest.nix"

    # Platform-specific packages to fetch hashes for
    PLATFORMS=("darwin-arm64" "darwin-x64" "linux-x64" "linux-arm64")
    # Corresponding nix system names for sed matching
    NIX_SYSTEMS=("aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux")

    # Get current version from the nix file
    get_current_version() {
      ${sed} -n 's/.*version = "\([^"]*\)".*/\1/p' "$PACKAGE_NIX" | head -1
    }

    # Get latest version from npm registry
    get_latest_version() {
      ${curl} -s "$NPM_REGISTRY_URL/$PACKAGE_NAME/latest" | ${jq} -r '.version'
    }

    # Fetch platform-specific tarball hash
    fetch_platform_hash() {
      local version="$1"
      local platform="$2"
      local tarball_url="$NPM_REGISTRY_URL/@anthropic-ai/claude-code-$platform/-/claude-code-$platform-$version.tgz"
      ${nix-prefetch-url} "$tarball_url" 2>/dev/null | tail -1
    }

    current_version=$(get_current_version)
    latest_version=$(get_latest_version)

    green "Current version: $current_version"
    green "Latest version: $latest_version"

    if [ "$current_version" = "$latest_version" ]; then
      green "claude-code-latest is already up to date!"
      exit 0
    fi

    yellow "Update available: $current_version -> $latest_version"

    # Update version
    ${sed} -i "s/version = \"$current_version\"/version = \"$latest_version\"/" "$PACKAGE_NIX"

    # Fetch and update hashes for each platform
    for i in "''${!PLATFORMS[@]}"; do
      platform="''${PLATFORMS[$i]}"
      nix_system="''${NIX_SYSTEMS[$i]}"
      green "Fetching hash for $platform..."
      new_hash=$(fetch_platform_hash "$latest_version" "$platform")
      if [ -z "$new_hash" ]; then
        die "Failed to fetch tarball hash for $platform version $latest_version" 1
      fi
      green "  $platform: $new_hash"

      # Update the hash for this platform using python for reliability
      ${pkgs.python3}/bin/python3 -c "
import re, sys
with open('$PACKAGE_NIX', 'r') as f:
    content = f.read()
# Find the block for this nix system and update its sha256
pattern = r'(\"$nix_system\"\s*=\s*\{[^}]*sha256\s*=\s*\")[^\"]*(\";)'
content = re.sub(pattern, r'\g<1>$new_hash\2', content)
with open('$PACKAGE_NIX', 'w') as f:
    f.write(content)
"
    done

    green "Updated $PACKAGE_NIX to version $latest_version"

    # Show what changed
    echo ""
    green "Changes made:"
    git diff --stat "$PACKAGE_NIX" 2>/dev/null || true
  '';
}
