{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.250";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1kr9zjdf9f5xvz6fx5an062imwpkagb3r9m6bwhizpc1p3h64ngr";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "10vxb05qki8wsyv8b96lf6lyskz8jshp04m1vnq2dqarnw3alhkl";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "13nvx6dj1f47h56ca68gzpn2adb9x6l7n8xl8m3rffz3bpgn6ym1";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1ib0n4vdyf6ragahhrx7mhghnj19w91cwxm3p00xm8pdsgabis3y";
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
