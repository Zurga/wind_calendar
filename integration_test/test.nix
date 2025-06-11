let
  pkgs = import <nixpkgs> {};
in
  pkgs.testers.runNixOSTest {
  name = "test";
  nodes = {
    vm = {lib, pkgs, nodes, ...}: {
      imports = [ ../service.nix ];
      services.wind_calendar = {
        enable = true;
        migrateCommand = "WindCalendar.Release.migrate";
        seedCommand = "WindCalendar.Release.seed";
        environments = {
          prod = {
            host = "localhost";
            ssl = false;
            port = 5000;
          };
        };
      };
    };
  };   
  testScript = ''
    vm.start()
    print(vm.execute("ls /etc/systemd/system/"))
    vm.wait_for_unit("wind_calendar_seed")
    vm.wait_for_unit("wind_calendar_prod")
    vm.shell_interact()          # Open an interactive shell in the VM (drop-in login shell)
  '';
}
