{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.196";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "08cdsl6yc6xpwvdirwgb1kplx9mkj85qkh0zw9kr86j6wksqcmz0";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "118rspf6mpj43z0cvfvwmb50x5m5q6iw22nm1gzkvm3iqwczpww8";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1gl42ybfri2hgz02dd8z3y8nfc6g03kwr5ya5074j058hsprh7vs";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0jcpbin20p8ccr6g53abr9jh11zch0pa4byrxl383qgw7waa2wzw";
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
