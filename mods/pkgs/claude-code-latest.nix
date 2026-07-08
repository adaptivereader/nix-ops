{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.204";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0rxywk1mk8i1sh7yf2ic1l4wa3pibk3gk60320a2vaiaawz99sg1";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1dffifmg93d6kil2nzwib8h7xa010ar7ix981hd84z68b33v1003";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0258ps3h98bmgbrm8axxpd1pzikimvmqj1h5kznwakgag1fw5qvy";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1ya7q1hmkhq3gmnj2akpz1r9czsw5b9pcqj3fk9758045rg2xi93";
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
