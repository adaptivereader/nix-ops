final: prev:
let
  inherit (final.lib.attrsets) attrValues;
  j = with final.jacobi; {
    inherit jfmt nixup nix_hash_adaptivereader nupdate_latest_github dtools ktools nixcache terraform_1-5-5;
  };
in
{
  inherit (final.jacobi) pog __pg __pg_bootstrap __pg_shell;
  inherit (final.kwbauson) better-comma;
  adaptivereader = final.buildEnv {
    name = "adaptivereader";
    paths = (final.lib.flatten (attrValues j)) ++ (attrValues final.custom) ++
    (with final; [
      codex
      gh
      git
      gnused
      jq
      nixpkgs-fmt
      nodejs_24
      npm-check-updates
      overmind
      pnpm
      toybox
      typescript
      awscli2
    ]) ++
    (with final.nodePackages; [

    ]);
  };
} // j
