{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.270";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0qflcwmdlcckxgss3wzx57ixh8s40xffr9h6k6l8rw49ylnchcqj";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "111597ilyzg2s2qyjwf8kfxji7zdwkspz1sn1rcxar0x4i5k39mf";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1l3dnx7d7snc6iyampzh4gyizrad15qrgh8n0q5p7nprffbvdh52";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1wz9hwjn9ikmx6mw4r373qjr6la2adf8cj08wbjwhz79agy54b4w";
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
