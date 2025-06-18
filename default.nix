{ pkgs ? import <nixpkgs> { }, port ? 4000, appName ? "wind_calendar", branch ? "main", commit ? "", ... }:
let
  beamPackages = pkgs.beamPackages;
  inherit (beamPackages) mixRelease;
  # Uncomment to use a git repo to pull in the source
  src = builtins.fetchGit {
    url = "git@github.com:Zurga/wind_calendar.git";
    rev = commit;
    ref = branch;
  };
  mixNixDeps = pkgs.callPackages "${src}/deps.nix" {
    overrides = final: prev: {  };
  };

  # This will use the current directory as source
  nodeDependencies = (pkgs.callPackage "${src}/assets/default.nix" { }).shell.nodeDependencies;
in 
mixRelease {
  inherit src mixNixDeps;
  pname = appName;
  version = "0.0.1";
  removeCookie = false;
  nativeBuildInputs = with pkgs; [ esbuild ];
  erlangDeterministicBuilds = false;

  PORT = "${toString (port)}";
  RELEASE_COOKIE = "SUPER_SECRET_SECRET_COOKIE_THAT_NEVER_TO_BE_SHARED";
  SECRET_KEY_BASE = "SUPER_SECRET_SECRET_KEYBASE_THAT_NEVER_TO_BE_SHARED";


  # Re-add the following line to postBuild if you have nodeDependencies
  postBuild = ''
    ln -sf ${nodeDependencies}/lib/node_modules assets/node_modules
    cp ${pkgs.esbuild}/bin/esbuild _build/esbuild-linux-x64

    # for external task you need a workaround for the no deps check flag
    # https://github.com/phoenixframework/phoenix/issues/2690
    mix do deps.loadpaths --no-deps-check, assets.deploy
  '';
}

