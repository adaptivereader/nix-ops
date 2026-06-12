{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.173";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0lqrvx18psnc1cf7p2riyjgngbjxvsdacy1chxijj81s0xccxyzr";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "16ngx2br7lg2wz836day26f22m6aym27mbz207ychrypq88v2i6d";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "09yf2i90i52rp5bpkdnm4d8w3z8mmd52349r0d0bi9pp934xj9rl";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "14zd3xrhh42n0wn6s3h5z1mmyk7spqsas8hyjx9y14widj1lj5qd";
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
