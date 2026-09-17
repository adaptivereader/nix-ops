{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.274";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1yqyzxjl5il7pnfpwv03ffkr5wj1jm5arf4ra4jzm16hf0slmips";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0qzf5rdffdmbjniv5pqmnfj39kca1v9lc0mifvbdk1sjqn2yibbi";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1q663jp333vd19y5sx03927qhca2ywxgb3gfmxf7119lvyp9dsmi";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0g3f0cykfkc64gm16yb7fgipscgr203f95fin7w4srz56q46yl5m";
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
