{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.123";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0qd31kn5gfnvsslj2q2bqcyl6ld1qc881j8rhmmm357gckya05n1";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1v6y6k6rdsfq1hnrpr135cvq80ix9n92p6qff9mw833qlrl33b3d";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0b39cgczd5g30nl281r9y7chqrvsb2j95gqh3g9iif2sa2bhq0s2";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "044pgj9s5i88fw006xz5b9v22dlygy2fy7mi1kmxl930d23y71aq";
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
