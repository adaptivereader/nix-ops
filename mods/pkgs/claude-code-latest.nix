{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.169";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "07r27b1y4mzwn62ijsx0xyzcbiwqlr29p8y3mhbb0cy18v89fd2d";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1wgm6l4zndgpdwqa5lf6zmrn7kssm9iq7vkwr0fpgsmn1z1x0avg";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1gh05j2dpsy6zcwwk18dyy59lgfgm51fippc8avsx9pd93d5xd5j";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1qwfw4cpimf9lrsh2rnxqvzs8jkxymgq6d8hmlj3x1vf4z624n4k";
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
