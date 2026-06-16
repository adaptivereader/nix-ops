{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.178";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "06681lz3ap4v3pfbnd6mq5lamv121g5li1xj2lw7cjgh482qq94d";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1q7dfmx26xic7183fyi6p2b54n0c0i2p49i09dr84p0261pwk618";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1ka8v2l2pf6cv3fqsj831mp84x36gk5l2jdwr3hdas15lrndlgfg";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1185fv6idn5ypq4s8ar8h319f8cy09511mzn0y0xq9j2jjc62dq1";
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
