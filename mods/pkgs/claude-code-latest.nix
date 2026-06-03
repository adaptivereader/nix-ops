{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.161";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1a8i15g1bdsx6545yyg7143224rp2dmc4fd6m57my1n1ca94z0ps";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1faa0029f7z3fnlxmxj984ql35qfnhsakczfvh9l1fq92p1xz7y4";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1db5v02jp5vsv06z1p1p8r4cyam0njv7adzrlppfnyhsvvivmgzk";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0rm0gscbybh0zylg3fbwfyzm1ngp2xj6y681q433wnaqpqxrfzg8";
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
