{
  nixpkgs.overlays = [
    (final: prev: {
      calibre =
        let
          cudaLessOnnxruntime = final.onnxruntime.override { cudaSupport = false; };
        in
        prev.calibre.override {
          piper-tts = final.piper-tts.override {
            onnxruntime = cudaLessOnnxruntime;
            piper-phonemize = final.piper-phonemize.override {
              onnxruntime = cudaLessOnnxruntime;
            };
          };
        };
    })
  ];

  services.calibre-web = {
    enable = true;
    listen.port = 9088;
    options = {
      enableBookUploading = true;
      enableBookConversion = true;
      #      calibreLibrary = "/data/media/calibre/books";
    };
  };

  custom.services.caddy.virtualHosts."books.494203.xyz".extraConfig = ''
    reverse_proxy http://localhost:9088
  '';

  #  networking.firewall.interfaces."enp3s0".allowedTCPPorts = [ 9088 ];
  #  networking.firewall.interfaces."wg-discord".allowedTCPPorts = [ 9088 ];
}
