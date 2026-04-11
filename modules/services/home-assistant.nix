{
  services.home-assistant = {
    enable = false;
    extraPackages =
      python3Packages: with python3Packages; [
        # postgresql support
        psycopg2
      ];
    extraComponents = [
      # Components required to complete the onboarding
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      # Recommended for fast zlib compression
      # https://www.home-assistant.io/integrations/isal
      "isal"
      "webostv"
      "local_file"
      "local_todo"
      "Philips Hue"
    ];
    config = {
      homeassistant = {
        name = "Home";
        unit_system = "metric";
        time_zone = "GMT";
      };
      http = {
        server_host = "::1";
        trusted_proxies = [ "::1" ];
        use_x_forwarded_for = true;
      };
      feedreader.urls = [ "https://nixos.org/blogs.xml" ];
    };
  };

  custom.services.caddy.virtualHosts."home.494203.xyz".extraConfig = ''
    reverse_proxy localhost:8123
  '';
}
