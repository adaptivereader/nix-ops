{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.186";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1d43rssb6vrh5ajds3qsgb2rjvbwkvgipfs59llr0ilqz518cil0";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0w15ag4hrwlan8m7wykwpzj6g0c7iayslsig0jnxdym274vh9c16";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0dlqbcr03qlwbhsqkns8x6s1hbnl7h5v84scqnw8m15gvlgja39s";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "17g8jmnv6zmzcib7dfak1119xzdf2s84wqsyhaxajdsxs4qs3f4g";
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
