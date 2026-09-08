# [supabase-cli](https://github.com/supabase/cli) is the main CLI interface for [supabase](https://supabase.com)
{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, installShellFiles
,
}:

let
  version = "2.117.0";

  platformMap = {
    "aarch64-darwin" = {
      releaseTarget = "darwin_arm64";
      hash = "sha256-yKKYBls3SDakKUX114q5NI0yi8/QmcFNPlsLU3eRIJs=";
    };
    "x86_64-darwin" = {
      releaseTarget = "darwin_amd64";
      hash = "sha256-a/FL91j4UU6kujoAIMFeq+xvbtx1JWFDRf2mwAgq5j0=";
    };
    "x86_64-linux" = {
      releaseTarget = "linux_amd64";
      hash = "sha256-acBfhbnkfucG0w8abKilJrTjN7/RLH7x71ItJOcoDSQ=";
    };
    "aarch64-linux" = {
      releaseTarget = "linux_arm64";
      hash = "sha256-WYxWqTb98XnqSGcXkB5uSbxdd3s60xfqsC9B+vIalcs=";
    };
  };

  platform = platformMap.${stdenv.hostPlatform.system}
    or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "supabase-cli-stable";
  inherit version;

  src = fetchurl {
    url = "https://github.com/supabase/cli/releases/download/v${version}/supabase_${version}_${platform.releaseTarget}.tar.gz";
    inherit (platform) hash;
  };

  sourceRoot = ".";

  nativeBuildInputs = [ installShellFiles ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall

    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"

    install -Dm755 supabase supabase-go -t $out/bin

    ${lib.optionalString stdenv.hostPlatform.isLinux ''
      # Completions execute the CLI before the normal fixup phase runs.
      autoPatchelf $out/bin/supabase
    ''}

    installShellCompletion --cmd supabase \
      --bash <($out/bin/supabase completion bash) \
      --fish <($out/bin/supabase completion fish) \
      --zsh <($out/bin/supabase completion zsh)

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME"
    test "$($out/bin/supabase --version)" = "${version}"
    $out/bin/supabase start --help >/dev/null
    runHook postInstallCheck
  '';

  # The main CLI is a Bun single-file executable with an embedded payload.
  dontStrip = true;

  meta = with lib; {
    description = "Supabase CLI. Manage postgres migrations, run Supabase locally, deploy edge functions. Postgres backups. Generating types from your database schema";
    homepage = "https://github.com/supabase/cli";
    license = licenses.mit;
    maintainers = with maintainers; [ jpetrucciani ];
    platforms = builtins.attrNames platformMap;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "supabase";
  };
}
