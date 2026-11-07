{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.319";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "05kfv172lnifxxxrpcccdlj19mm8qh1wkqj2d21rgnw665nigm0m";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "033gcxwa65b95h00bamw26wqiha3nmldcx0jx1qnh4ypjn1lbj9g";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1isxg750qkd6bgb58bxgi9gc3rg9w3qrxzpfmxpqiywg9fam6ywv";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0dl0dxdb2rd9ip1jlvcpjayf2vwx5nnhcag8cfag6grqdbm49kpi";
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
