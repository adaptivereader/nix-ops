{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.147";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0w7kkhlylp3psilbsvsrhc2ky2fpm7ck9hng4igwwx6cmjbi3p76";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0l13zcwqx3lf1j8h7500vvkpi1sld2p6d1dkjmvxch8np7aaybfa";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0q6mdih8k1ip7k9x2j080mrzj68afjg3vs58gi7gwvg67f4jkmi3";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1g0fv91pbxmckjd8s94bv593wlyidpqlanzj9mpn3wzs37m5axca";
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
