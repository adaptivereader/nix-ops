{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.269";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "184bk9knbr9jfrdiclvzg116lx4nb81nl7dkmmw4x7jg8z9p7jd6";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1q714gqgp5lwckpvaky5s8ydl9sh2jyx3ki6ki95ksyvxvhjijj7";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "19v2785hb7bkkg3y69qs63960v72fdjlcsmcjx2jq19gawvy4vam";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0rf7nw3d7683398pgdz3s0hb5ikfifsxg9083ybazlf5p0563qv1";
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
