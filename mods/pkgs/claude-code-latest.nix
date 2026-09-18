{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.276";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0mf0hdjrlzqccjpwh1hp9qqw92qba7qzgraaw5ar4rw9zq4r5alb";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1z61p7iz4b61ww155ws3j85yqxk4ss1i2ci0cn4j6y93flp9ylys";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "00cknh66vbddnz7j9r31v4yqpv3rhq1hpqw6whcry6n3b2cicq79";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0cli6kh3z4z9dp8pmgvj2dw8lg55s0h99zidz83wk0nkv66gksfm";
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
