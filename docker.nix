{ pkgs ? import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-25.05.tar.gz";
  }) {},
  # Optional: pass path to docker dir for better cache reuse
  dockerSrc ? ./docker
}:

let
  agdaFull = pkgs.agda.withPackages (ps: [ ps.standard-library ]);
  stdLib = pkgs.agdaPackages.standard-library;

  agdaLayer = pkgs.runCommand "agda-runtime" {
    buildInputs = [ agdaFull pkgs.coreutils ];
  } ''
    mkdir -p $out/bin
    cp ${agdaFull}/bin/agda $out/bin/
    strip $out/bin/agda || true

    # Standard library
    mkdir -p $out/stdlib
    cp -r ${stdLib}/* $out/stdlib/

    # Agda config
    mkdir -p $out/root/.agda
    echo "$out/stdlib/standard-library.agda-lib" > $out/root/.agda/libraries
    echo "standard-library" > $out/root/.agda/defaults
  '';

  proofToolsLayer = pkgs.runCommand "proof-tools" {
    nativeBuildInputs = [ pkgs.coreutils ];
  } ''
    mkdir -p $out/input
    mkdir -p $out/output
    mkdir -p $out/work
    cp -r ${dockerSrc}/* $out/work/
    mkdir -p $out/work/Input
    chmod +x $out/work/check
  '';

  dockerImage = pkgs.dockerTools.buildLayeredImage {
    name = "agda-proof-checker";
    tag = "latest";
    contents = [
      agdaLayer
      proofToolsLayer
      pkgs.bashInteractive
      pkgs.coreutils
      pkgs.jq
    ];

    config = {
      Env = [
        "HOME=/root"
        "PATH=/bin:/usr/bin:/usr/local/bin"
      ];
      WorkingDir = "/work";
      Entrypoint = [ "/work/check" ];
    };
  };

in dockerImage
