{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.119";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "038dpfmd4s9jjz3alg35swy9aj2jrclwvflfj8fnzfm3q5m5z7hl";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0a11klb0yf5vvhwxg0npnkbqiwamyp8gqgalc0razkyb4k94dhxi";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1a4wms0idjkjsby9ib08bpcs1vmd8vmi3w01cq4xrh9ghr59b5ra";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "028ky2zg98hm5hg3kqh0q8q7i78qcyj3r5cgbg8cpdzw58ya563g";
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
