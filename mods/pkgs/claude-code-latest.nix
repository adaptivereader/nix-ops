{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.238";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "13kwgj91qrl70jmba03lznq3c80c4w820a8wqv4559kk84pwqs87";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "19a2winbr018kydsdv0akyrrwr9w5xshsinphjs3jcnq4r7diz76";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "181sb0pkswygsn74q6si9fm7fik0h1vpb9w4ya5jyja02pvz0syk";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1d0ldk7vx2g60ggp8j37w4nk1ii1l9wfwy3fcj8682rcfvjgq9ay";
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
