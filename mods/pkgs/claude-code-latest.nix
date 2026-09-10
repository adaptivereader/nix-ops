{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.267";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "18mahv0n1rjchn77vrrirywvmjh1fnbibrm6j2wrc8bl53ny1qya";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "103992zdv91l659vqwf4sprrv7i7sviqinbn6nqr1la8418gzixq";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1m9rf04kcc9yk7b5fk458b72b7k82jiv4b4rx84sm85pi9jmh0h1";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "074nv771ap5waww26iypb9yxqcr52hdz9d4vqgfw3iiqk7r08i8r";
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
