let
  pkgs = import <nixpkgs> {};
in
  pkgs.testers.runNixOSTest {
  name = "test";
  nodes = {
    vm = {lib, pkgs, nodes, ...}: {
      imports = [ ../service.nix ];
      services.weather_calendar = {
        enable = true;
        migrateCommand = "WeatherCalendar.Release.migrate";
        seedCommand = "WeatherCalendar.Release.seed";
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
    vm.wait_for_unit("weather_calendar_seed")
    vm.wait_for_unit("weather_calendar_prod")
    vm.shell_interact()          # Open an interactive shell in the VM (drop-in login shell)
  '';
}
