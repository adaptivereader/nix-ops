{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.206";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1kpl61k2y2h5b620sc415d63hal0gwwawfncvnkvaw6y6k1c58v8";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1z9kvqlxp5cbj874br29vmvmbwkiwp0fk17flnwghz0sac0qz6ll";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1s3hhl2dbnjby10pm6py31n95pfmjxgd7zhc314l9ahyf0m2d3vf";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "16a0ngx757piqzrh8zi8jl99gmg32lwvvd77x3hcx2gp38p9b2ln";
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
