{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.154";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0jh6xmxkkmilqrjcdb3sacmhbi2h8sawfc5hijnalg15cnksz513";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1dazhwn0dysd89sc5hypdbf0wpdhj58nk5binvkhhy7h4kj3nr4m";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "14ykdswcnmlah5hvhrb77k5b26c6xs5k9nl5gwflvinxlv0acjy3";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "080a0kpa6hw25zkgwy3bidx5iqfdsckwxmakpfyz8qbz8qjxnp1l";
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
