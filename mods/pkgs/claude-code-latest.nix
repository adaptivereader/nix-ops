{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.234";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0qqr1cm8zbrlcxv4mbc2bxhvnyafapnl6hf6wlc5kj9zngzsnidy";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "15r712zzsss2ryf8k44xnw3yvfcipwb7hjada9qylim0z7yy19w3";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "18spgj62anx161ljn2yvw27g98jvh9pk792bdn4yycxxiwrbx68g";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0ipws74zh12r0kwi268n2lak1dh7059l1aaky54s73n05d9i019a";
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
