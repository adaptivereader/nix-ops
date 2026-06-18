{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.181";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0n56v7g2q8snk4jbvgv7x6pd6kls81kc08vvlqz4kjsms76iay8k";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "1bf90si42ln4d09hblpg8pg2nbicwj3alqcdjgai5nr3gn557i71";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1sf8sqbx9xrnkh4sykg35h1hkryprji90xsdha398y0mvk8wrvjd";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1vj94b3a6csy4bw3bl3xvmx4bxgl3r36llanh162zxgb50nn6i87";
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
