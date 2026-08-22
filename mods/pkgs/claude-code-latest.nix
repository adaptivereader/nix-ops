{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.239";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1bcl9bqy0jyd904nmzxwl4zgw0n0bsrf2cmsnmgs9jik1jvgqydx";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "028sx9fi3132z7xv2ccbflw9dcrvwybhyfvdr8jigmhrr2kmc1hq";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0b57n6v1d6na01n53cwpqagqyxpxsnv06c49v1r9slpfalvc6qv8";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0spic5gsvsc50g6bs6h6ybvciw5fc3prirxc4n1bpq48322xykls";
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
