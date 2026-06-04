{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.162";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1bj8sfa65wg4r9v00jhcmlpd8ymi58r8fjr7z76nxkrnb5vqfgy0";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1isvnp4gp05fakqnqq136bibyppsyhcifd3qcyb3qx1l9a7b35cp";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "02sxbpar561xcn6m2lqa90ivy9j7ilh66lk2y94716fqs375brw0";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0838hnxkav0xkk5p4v9fa2ck78ggcvwlcb5yaj1bx6pijg9xg9qi";
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
