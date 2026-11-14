{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.325";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1b388q39vr8kn7bw6qzi3dv2c0mdk1slxd30gd7lmswi0ib8qjbz";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0c3gv4s984i2w0fs80xkzvv6gsa91sl7bf5biib5yi62831dy5hn";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "07f35b9qibmk8rihdhkjbwgnvgmsr30dip63clfw6j8za8vmswz8";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1vww8lcp5v49ynnmyyzjmn14qbw1srkapb0vh0mbclr5vr7202pm";
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
