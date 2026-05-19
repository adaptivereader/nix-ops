{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.144";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1k44kr194965pb3i8irw1c3m9jlfjxh2vs0bq4zddlkmay3ajdb0";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0nchjbc6nwdy6fldpynbfxlpkq5yfd0rf578wf2nimiw9glxb72k";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1lm27y6938m1pf7yhn82axvpjbw16hxsjwh3l9hrvjbsnn6zvbpb";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1prczifv4jw2a0hqqa8fr5p580l9jlyyzx3m1i64bvjm8jk60jqj";
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
