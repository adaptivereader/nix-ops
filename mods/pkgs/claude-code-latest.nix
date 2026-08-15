{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.233";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1paf4cz5yrwcwydiflnp6s1sm7jcs77x7kvyd41iphpy5lcp6qx5";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0fir469yv57zil24p6da9a4ia66af9wp7nxmm78w6ijlksfs8gic";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0s4givf1dzg0xwrg313bwzdnvlfnalgk0g2fvvimn9knam905d7v";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0iyy171b49alxcydjig2rx3hrbscf62gyjnmgs5yyalwizgwfa7v";
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
