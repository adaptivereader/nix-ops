{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.293";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0rh9474mjzypxqdy124l5hi18i3fpib119l3aam1q5kiqnvvyyqc";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0zcznnw103rvhrmfgk8spzyp7cfizy63a9il8v55pswzwcsqmz8z";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "03ypywhwynxk0lx37gl2klxqi4bbd5kqkhfzynh1zpp9m516hvbv";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1fdh7mdmhlp4hbms5k4vdmdvgk5r2x0xikswhhcr39zd88q2aabf";
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
