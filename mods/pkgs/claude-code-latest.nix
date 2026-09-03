{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.259";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1f7l5g5zpvl39jcwidpvp7a9k4irhjkh7s1pv1csv7fk7mrp17lp";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0fdc4r8bwp5vy3h2qjrl5yw10xhgzdyx9hqyzjcia5byg9194h9w";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1mprxfvf4wd83gmblf1wl1a1ianznjidjm7b2hyx8x1dhbg07prz";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1fp15217is4c6hadbv53ipxzqax64zbvc53dfrjjgh8mj4s6njni";
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
