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
}
