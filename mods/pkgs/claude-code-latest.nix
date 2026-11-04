{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.318";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1flnbbkj6zv6k3i6krl7caf9anmahkkp0dr66gysd5mx9fw8d9h2";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "10kppw676kzxm37qgw50j6kvfmgxp6ig7xn9i3xnrm2vj4b6sfh7";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0ksmklpyizh0mvf926b8cbqpmxcpxacvsm8rpdcjkggms0xmwk9a";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "12kc86pgriabgxphkpp6cpfyq1j9jb213h6iqv5si0lpdsig97s2";
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
