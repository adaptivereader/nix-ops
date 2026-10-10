{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.296";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0n3l399dcxxjpxvrgg72cfwfd6nq11db9f36gnp9lv2jssagbysh";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1i1z1dglqrp3qb9i7p7l6dm97mrwpdzyw1j6qkw0rizpy1idjagc";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1qfh9wgc5wpbl01chmk2gxngrrss6fxb7lc4wwn7splsn3ia5xgf";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1law0j99kydmlf4jdf23wjxk5p3dhnsfhnpgzrxb7rc5zhfbxasn";
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
