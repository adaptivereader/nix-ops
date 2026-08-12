{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.228";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1z7s3xz9rnm8zsw4q1dr8jd6j533w8w5rqxp7ycfwq9zpw1rvkkx";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0wvxf6pmxd7whmlahf05n0s2lnhicbx4c6h1jfwz6bmx091wq7bc";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "1n1zvsnvyrdd97cbk069cw6ic1iwl72pdnwdp3z2wgkmv7d4wc0c";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "09vy1n6aa5kdqq554c1hs6s7yijp4yc4d2wah4dmn8zgi8qmla9i";
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
