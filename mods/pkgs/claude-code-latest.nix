{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.273";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0jz0lgs8xkmnn21849k69g1rvrvbs6c3ls5knvfxy55nd0nynwll";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "08jsv38y78rl4rvpgkynhwhdnibqfqdrqjnkvmqyz520iyfd8bd7";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0g0hvb53wwsvg5lh89vl4irax2qpn4fklgnnv43wsf2vvkh7jxmb";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0dzmsq799gr25l5yxcr4v1krxqxz3zlgm2mhbck8mynrjsqs0c10";
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
