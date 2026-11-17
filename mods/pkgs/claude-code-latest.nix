{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.326";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0dl13rbxi7k7fkdfy1d6dg5a92m0z2w9h75qi2axzd8r16w99adx";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1lxidam2i7v3r07ydc6v0kngiy48z90dacm5zgzw5ick5ii31xmc";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "16spyma5n2j81gscfa1xbclmzzv01w3m44l4pfw98npfz5c6nfhi";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1155p77vgb7m4a56p16mqikk3gqxipgl1hf969bzsizfhv00giq4";
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
