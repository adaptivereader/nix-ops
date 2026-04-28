{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "2.1.121";

  platformMap = {
    "aarch64-darwin" = {
      npmPlatform = "darwin-arm64";
      sha256 = "1a1np3dh555i9vzqvmwrzam6cmqgvrnq34ja7w7jmjhsavlmvi8k";
    };
    "x86_64-darwin" = {
      npmPlatform = "darwin-x64";
      sha256 = "12b0vjdxgx1hlkcijnq471yqnkr2qmb9fwvyhbd1dr1i8krmfdxl";
    };
    "x86_64-linux" = {
      npmPlatform = "linux-x64";
      sha256 = "0cv1m45qfwcf2gdwdf2bvxfzphsdvigjq4vvap6z82c0m6brxfrf";
    };
    "aarch64-linux" = {
      npmPlatform = "linux-arm64";
      sha256 = "0gxrvcnfisn7ibkkh95q7bfaqchdnpnjr124wj86zvfwl26lh5l7";
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
