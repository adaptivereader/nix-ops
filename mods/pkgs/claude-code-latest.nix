{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.218";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "024z08rh88h0ff90q1an194ffmsg77kw51my2jzb3cxq477hck6i";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0wbg4mall8wl1l202lshi86gf28s4pc9k480lf279ylqln9v4qp9";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1yy95qrygbwdvmrsbsvvdpvkazz20dqv9zwasghaggjaakrxb9rf";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "06cnmzj2gb6vg2s5gsi5xc0mqkqapakld82bwclkjr8b5zhvag0x";
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
