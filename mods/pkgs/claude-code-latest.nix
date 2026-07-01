{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.197";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0vmyfvxgy3hhzd4gz3f0fyzpl7vqb4c7qa5y4k189ay3d5gv19zm";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1cg2vb9hlkrin23pnp2xs1n2l0cyiaq2aq8h46sv1ipw54n5cw4b";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "050vc8q3f12zzkh2jdl7mll1ba23fsiwrklsni49yzfml6kjmca2";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0hgs2bhyn71ydxlxwx246ycgal41wfg772bjmhkyd1kcinxl5cb1";
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
