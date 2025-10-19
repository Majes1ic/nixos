{
  services.ollama = {
    enable = true;
    user = "ollama";
    group = "ollama";
    port = 11434;
    openFirewall = true;
    acceleration = "cuda";
    loadModels = [
      #  "llama3.2"
      #  "qwen2.5-coder:32b-instruct-q3_K_M"
      #  "qwen2.5:32b-instruct-q3_K_M"
      #  "mistral-small:22b-instruct-2409-q5_1"
      #   "hf.co/bartowski/DeepSeek-R1-Distill-Qwen-7B-GGUF"
      "qwen3:4b"
      "gemma3:4b"
    ];
  };
  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 11111;
    environment = {
      SCARF_NO_ANALYTICS = "True";
      DO_NOT_TRACK = "True";
      ANONYMIZED_TELEMETRY = "False";
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      WEBUI_AUTH = "False";
    };
  };
  networking.firewall.interfaces."wg-home".allowedTCPPorts = [ 11111 ];
  networking.firewall.interfaces."wg-home".allowedUDPPorts = [ 11111 ];
}
