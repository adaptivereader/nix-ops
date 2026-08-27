{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.247";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0zga6jjx0v4qrah5vkh2vhcbcfwa0b6dsa93y3dv0dydf5k931zd";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1idqx0vqvxl1ir7haqf1km0ik3gf00n4m0z0j0s6jf9c0lirml6w";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0wc4s4g7pnga789svpkh06fbhd3bjz501y7wcw8hlv4g9ykplsf6";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0jz5msff4kycqyhnj2ypqk9j1ghhn39k9q7mp73kbg3bfsaljf23";
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
