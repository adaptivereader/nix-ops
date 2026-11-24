{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.331";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1gzvqxk26l2bxfjsawrphhbcg9vmifag8jn7pfvpc3khk6rlq58p";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0cpvn7g0n736gbibfjac2cdh1a2mgjrf2cq0k53lkf5svn4h52pm";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "09iavbk24aj75qvv0am15b467678k62dha7733p7j9vddr8xzai9";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0jrgw3q4lcaq3by22qkib6z4c1sw7wa0jr649lk7f94p9743d04y";
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
