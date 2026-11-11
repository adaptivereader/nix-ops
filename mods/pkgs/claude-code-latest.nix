{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.322";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0s27bw3lfl7hbgx4saxh67pxs6l3ghmmh7wkisix5q6z0aadwswh";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0ykb4v20ywzx8x4dijyy354v929p27a85zhh2f8lh45rw043jp5c";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "06bjnla548m1483x348przw48cli5nylblspc2v0mhl057c7bh9w";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0p5fc4zxdkz3hjsb1gf4vjczvn3ffn38994hcfbklwqqyg0jmnkl";
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
