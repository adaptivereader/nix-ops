{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.185";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0xmlyx0dbksq4fmrz4lj0b6qyifwqa73kw4lkplrmwpf6inlkn0n";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0gwnn87d1qw1j3ykmk7nvv1mljav2q0jxxv46ipmbsjn74y5ph0z";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0y0vzffmcicyj75wsbki1h8qgdfn5lix61v5gfsw6945n46gjvxn";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0v4qn8r7gzf6hyc6yx01krax2rc0d543nz2mqh32r9sxd9ys0y86";
    };
  };

  platform = platformMap.${stdenv.hostPlatform.system}
    or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  src = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code-${platform.npmPlatform}/-/claude-code-${platform.npmPlatform}-${version}.tgz";
    inherit (platform) sha256;
  };
in
stdenv.mkDerivation {
  pname = "claude-code-latest";
  inherit version src;

  sourceRoot = "package";

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 claude $out/bin/claude
    runHook postInstall
  '';

  meta = with lib; {
    description = "Claude Code CLI - AI-powered coding assistant by Anthropic";
    homepage = "https://github.com/anthropics/claude-code";
    license = licenses.unfree;
    platforms = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" "aarch64-linux" ];
    mainProgram = "claude";
  };
}
