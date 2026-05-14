{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.141";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1cs3yr0yjqrn6ndhrs7s9nrizrz0fibc1rznmr2vk78bxbw2855v";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0zlq7ich66qaa0gzqgdzp1lfjvlxys139ka61irrmaj2bpns2gqx";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1hqfkgw8hmxwwfblqlzw96rrhfj2z8pycrdq50s18agkmvpixkq8";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0xyj4ar0n4slmdqda9qxfimk1qfr3avg3p449rnszfc3pnz6zsdb";
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
