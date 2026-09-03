# Update script for the official, platform-specific Supabase CLI release archives.
{ pkgs, pog, ... }:
let
  curl = "${pkgs.curl}/bin/curl";
  jq = "${pkgs.jq}/bin/jq";
  nix = "${pkgs.nix}/bin/nix";
  nix-prefetch-url = "${pkgs.nix}/bin/nix-prefetch-url";
  sed = "${pkgs.gnused}/bin/sed";
in
pog {
  name = "nupdate_supabase_cli";
  description = "Update supabase-cli-stable from the latest stable GitHub release";
  script = helpers: with helpers; ''
    PACKAGE_NIX="mods/pkgs/supabase-cli-stable.nix"
    RELEASE_API="https://api.github.com/repos/supabase/cli/releases/latest"

    NIX_SYSTEMS=("aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux")
    RELEASE_TARGETS=("darwin_arm64" "darwin_amd64" "linux_amd64" "linux_arm64")

    current_version=$(${sed} -n 's/.*version = "\([^"]*\)".*/\1/p' "$PACKAGE_NIX" | head -1)

    curl_args=(--fail --silent --show-error -H "X-GitHub-Api-Version: 2022-11-28")
    if [ -n "''${GITHUB_TOKEN:-}" ]; then
      curl_args+=(-H "Authorization: Bearer $GITHUB_TOKEN")
    fi
    latest_version=$(${curl} "''${curl_args[@]}" "$RELEASE_API" \
      | ${jq} -er '.tag_name | ltrimstr("v")')

    green "Current version: $current_version"
    green "Latest version: $latest_version"

    if [ "$current_version" = "$latest_version" ]; then
      green "supabase-cli-stable is already up to date!"
      exit 0
    fi

    yellow "Update available: $current_version -> $latest_version"
    ${sed} -i "s/version = \"$current_version\"/version = \"$latest_version\"/" "$PACKAGE_NIX"

    for i in "''${!NIX_SYSTEMS[@]}"; do
      nix_system="''${NIX_SYSTEMS[$i]}"
      release_target="''${RELEASE_TARGETS[$i]}"
      archive="supabase_''${latest_version}_''${release_target}.tar.gz"
      url="https://github.com/supabase/cli/releases/download/v''${latest_version}/$archive"

      green "Fetching hash for $nix_system ($archive)..."
      nix32_hash=$(${nix-prefetch-url} "$url" 2>/dev/null | tail -1)
      if [ -z "$nix32_hash" ]; then
        die "Failed to fetch $url" 1
      fi
      new_hash=$(${nix} hash convert --hash-algo sha256 --from nix32 --to sri "$nix32_hash")

      ${sed} -i "/\"$nix_system\" = {/,/};/ s|hash = [^;]*;|hash = \"$new_hash\";|" "$PACKAGE_NIX"
    done

    green "Updated $PACKAGE_NIX to version $latest_version"
    git diff --stat "$PACKAGE_NIX" 2>/dev/null || true
  '';
}
