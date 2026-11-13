{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.323";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1p3d1cxibq7lvv70zphyd0cqkvqzcg38yfmxj4lfc6p3is3kp4g4";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "17qhix918lbpvz9vy8jzsygphwsh79vs4zhn0v5py4709yvqci9n";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1qncxgq9ibj9581138wz6lq939kak7v7jwg8fg03jwhfv7xj696i";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0y5dyhrvr23izp4gy4vsjr3l278a5caqql1r0q7d137f3ywcyy7h";
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
