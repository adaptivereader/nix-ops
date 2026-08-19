{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.235";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "17lf7954d26xldrp062b12hcjrxpzj7av4yqh15awnsnancdr17w";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1xrkd24agykrqqgdgmkzqmdjw16844sy32in4dh171ksnb4p2qrh";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1rq4cdvlwl6nmzbafvcaq1146mhh0cgfgkqshansbwxfxrrv4l4f";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0vs731mc77rrnibzacg46c03svqbzbpvsws21sqxqyw1yh79zwig";
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
