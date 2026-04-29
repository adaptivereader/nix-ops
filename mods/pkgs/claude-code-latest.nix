{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.122";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0nbv2mrqz342b000kgmvqbcf51iv5w9pir2dlv2gy3ifwqwc94cx";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1z3afjigacsjiq996sgmbi02lpl0gxap7vssmnh5c6srdnhswj81";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "08fwk4jprx26aark7823ibw3vic17s2ypw3jk5qw1qwwhs2730yy";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1dsiy345p2f73ac8ibr1mykqwqw6xya5pbci1sp10v3lv3smyfw2";
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
