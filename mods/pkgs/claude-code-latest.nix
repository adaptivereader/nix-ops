{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.292";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0lfqw4w81xh03ygcw0kwb7xh936is7415pz91dm2qs83j0zmpf22";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0p06ws4gf3zg40qzawmj54i1rdw87p05gkg9cdnd6kz72xi87p84";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "00x5ay6h81y6kkpyvq5l9dakyy2h1j2wjfnrxynhrnvhzrnp52d3";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "00q04wgs16avdkb9ss7gk4w28akli9l8an9an31ml894522m0ckn";
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
