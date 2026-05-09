{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.137";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "16ghfyixmdllrzww8bwzygmznpn1b34ldsrgfaq4z5z7kz31z9w0";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "06jsqk60hsc67zx5lifcywn07sp17b05jmkyfrdmllkkjqjbg6rn";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1jid6jzyjcz9fgnw1s1xf4l1b903x8fzr74ap771arcfqc5drb38";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0kph4lh1fwwjd9hmn2z1sc018zw3zyjkbw9d014s3m5da6brg0sp";
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
