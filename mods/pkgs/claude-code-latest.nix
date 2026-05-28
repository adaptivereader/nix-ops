{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.153";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1iwnm8y2zf0jxsnksq7b77aygvmfs9m618cfvib8ragv4vc7hdvs";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "03j2i8qlm35kx3nki5r28sfgz1vn9pwfywnvpxkmffsksm5zc80x";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "019jhm0f630fnkrbmw7pdw6ibbw393y1sl060db8hibm77gr32b8";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0vm45vph4a8y54nra4mr5b17g4wi6650kpwpfc0y5v6b59xkqhah";
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
