{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.321";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "18ym2nk3r6wp825pz7jm2qsdnl4hbk3cgykvbdfqgllhy31639f2";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0jiasxffvr62hzry3d6y25f3hbw76bsbdnf4g4qfxqnxlknhyai2";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0jk6yynj7pzbsi6v6np1gafpw3w81rhhny7h0djixz3b5x62k7r4";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1g41hm1mi2dix6pzw4f5zks5jvpnc6wksaf9nkpqqphnc9nn4pcs";
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
