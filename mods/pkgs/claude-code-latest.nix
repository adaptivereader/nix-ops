{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.232";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "13x2vn51zf0ifx0knq8mx4mzgb2wbkzwiwcqh9w793wbi6nfhjas";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1byf8fbs86gg1z439hrxkr3r7i84h0n4pfixm51z8a2yl349q0hm";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "13hgsi7hmi2hg27x1am5948jy6pjgzif6anyy57zqg6z36lsy3nb";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "19lgz4z6fvzglijzz2qs4rwclx4q3k982adssa34x21wzy4j2clp";
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
