{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.280";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "18zlqzndz9z6p0d317smsd9j2d332sqy6rgazlcf25chyzp0q5vn";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0vrdw3gwpc2gad6yi8vi73dkdgpv2yvv59xj7ix6f95cwry9a6cf";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1lxza9nxmzhxazgfhsmg6ds563fsymjfpwvfaffzf0p300qmg59x";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "09m79dwf1lzkdj3pw7d9v8zbv5hklcs4dly88q6ys4gccm0k74a3";
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
