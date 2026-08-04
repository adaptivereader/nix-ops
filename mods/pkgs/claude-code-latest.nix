{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.221";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1lwwrsb8q6v6jfyw3xzsh8msla2d8k03551g43qyf9ryggw1wwq0";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0gs71lg1j15xc8a22mg8arx7s4nslrbhgkcnbx50jk9yl5vvsrjr";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0vdslvjsikwnwd0dwgbww444aj1l6qhg3p120lfwxzi87h3jdy1y";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "15sp8jchda1v3jc7703d51i8l15qbfjhmva2r8qc46qzanj6kixg";
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
