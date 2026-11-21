{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.330";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0fxk1jyr8w1y2kk19hks4g52acfvqncj24dnybj71dk7cmq1vjdq";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1a431jfnj75ph5zph1n03mzm4zjxn6wyq9db26kb52b1rbsyax7q";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1vs03kpj0rkcyc5rmzxklb1js7nxzkk6a80k6a09a8w7fv2k1zs0";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0vdzxybdx2ilkcl3rvi8ddblm8fxkrqikiky5byz8w36d4nd8q2l";
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
