{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.316";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1akv2irai0lp51fviyhff6py2zb4rql64xyvivpm4v6vr65ph59m";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "13njgrrbwa3p4wqxrqnl6spn5fwmip4hj5l8bhncj1wrqf5ihq96";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "000h911gl6g7x94i3qllc3n28wsd2khza02s30d1cxdldqcinpkl";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0pc7kmggbrfq974p5v8n7hclm7jz7cbb82z4wm0ip7f7l12qx51s";
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
