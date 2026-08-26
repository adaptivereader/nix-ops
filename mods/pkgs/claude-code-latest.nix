{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.246";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1sb51gx0q8dx95xzw30zqv940pc3czkq9idhsba2vaz7bp52lmhp";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0r7b81ndh6sqsbcnc41bxr8y10ia3n3l8sfh9n9prp0bq1fspyxy";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1ghwip81pw3g2f2czlm9d2zj3qz08jvxr8hmgmapjj4l2n90ca5l";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0q171am8fa67z05gzrs1n70rfmfa3g448bqz48gffyghxdf0i1m3";
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
