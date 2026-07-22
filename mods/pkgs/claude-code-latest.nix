{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.217";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1df7fflc4vqmlx51g01gi9019h0rclh2ahmzbjw27f0hwbpj30kl";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1vq2anbba7l8klpk7c99i682j5nva2y6y58wqyk79rrci4mmqnmk";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0m0si7k8vny0kw42g1d2nzaki2yynhjya3bxblnmjqbxsvzf71as";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "18rbq2cnmkv7qzn87j1fk1nymjwcfw3zzyn24xjb32vpc2z96lv6";
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
