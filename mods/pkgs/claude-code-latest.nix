{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.332";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1787kbfhfqsdiikxxlqdkp9hmibbiigqqn58hlm770z298xxm5am";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0nh1sm0mrsv6fk61a5y676gd2ascbpx3g3i6a32rrgypn2115jn4";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1waam39qfx5rncmlkwai0v705iq7zj0r3ppqrx13gsdyw3qz528w";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0dn2bjgmvs3r5bnksww4k7b20zk124nn19h6ysa10h9g37qia6hp";
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
