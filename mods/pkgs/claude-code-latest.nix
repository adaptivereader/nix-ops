{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.309";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "0lcskf3xhnsxx33ayr5l4d7917dqknv8ssdp3dk2jqanp3fy330f";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "0cscc0l8md3xzwqp3gxrmjw89l4c5bydlm9s6lwriifxhgmgrwjq";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "06pwqaa6z1wn9y311mzc39qi4pxd0hzb8kbq6y2696bggx1w8q79";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "1ci6g54kp7d0i2zkxcbd4pciayl2c6w9w9lqrxadcg3j0jzz221i";
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
