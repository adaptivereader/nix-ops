{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.300";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "07vsci120q6m182p759y56mvf83r299r7hhbji58hz2gk5d1frix";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1298d57jh5bghwgwkmnla1sni9jzqs4rkg2csnkj0mvdgf6zd5wa";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "012qssgcawpvr1ada648vj9mxm3zhq0w27bv3ckpfam1nlb58ig1";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0agv2zlsx8pakrzary5nkvcnar7ixqcjmbwd4cslpmwka02cgn0h";
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
