{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.176";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0949apdsb5fmbkksysafsmgfai2sllb35xvivwhr992jn8kz1ark";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "12dm9jyzsfixlihnqc84923nm9zr3d19m2hwc4kvaqyv1s8v3ahq";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1s8z8wvxh30fw7hxvpb0scm3z80vgkmc75s8ixwfkd1ya67lj8yq";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1i01h0p9l1s5w1yq4z13p8skgj51048xjya7612508wvgc0h33y5";
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
