{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.193";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0pj38vq2qc0rp57414g19dky1c3ggwcini056nja0wfn4mz9x1c2";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "12bjl3msb1cirk8srgyq5kqrg8a3z496xg4nw33xh2bqsj96qfw2";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "17kh77fqvpzwy6x7rjbz97acimjfyk34g8n4ryv6d52hyi27drsz";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1izwxdz53y49lcjzf7k50yskapzx3hhbwlp1jn1h4fy77xjccm74";
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
