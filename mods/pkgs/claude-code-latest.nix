{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.227";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0jq1az0pp39brjaic85h54jmmm7ypn20vff4aks1wadr743iabvd";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "03jq89xr2syygqjxcbam34r21ic4yh7ld4yjjlyv4cn1akdb983h";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1q6xx8ala3yl8s95c8qyysfg7cxrgnlzck73ld5kimwdmv8x82h6";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0q3c47lbmgr674y5gpwzp97092zq0dbjk0ygnpxqg75nqhc92nw6";
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
