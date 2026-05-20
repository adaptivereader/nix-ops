{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.145";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1xdbzk90i82gw81li9a2870ipxb9flh75fpln06hr4255i5hc5l8";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0gjk8anx0bdvh40fbxqf0sf10wi5kg6wk7rvhq3l36lysfpzqlci";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0llin36aangrhcw68zipfp2ysvmji6pahvp28f1rbm9wn1d0xhiz";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0yk9mm83f08bnv9xj1i04v47szfnfxm2nq4qxq45yrb7s5w4iqcv";
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
