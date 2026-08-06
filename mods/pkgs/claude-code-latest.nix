{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.223";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0vfmfy8xsa6m32ybvsa8m0k7gq0s15nchx08ww3xpj7kq6575l1r";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "18gc21q1qzda9xfp0lj3rr0hp5m8h6w9hi9k2ja399miq8zr7f89";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "11hs9brhjnwg1vd35a8y5bnx1q83g7542pfi91drrzj4bdy5qczv";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0hf4v046myjw538da8kp5ifhc0bis4r4qjimn7jrbsgv5g39xi19";
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
