{
  programs.alacritty = {
    enable = true;

    settings = {
      mouse.hide_when_typing = true;

      scrolling.history = 10000;

      window = {
        padding = {
          x = 6;
          y = 6;
        };
        dynamic_padding = true;
        decorations = "none";
        opacity = 0.7;
        dynamic_title = true;
      };

      cursor = {
        blink_interval = 500;
        style = {
          shape = "Beam";
          blinking = "On";
        };
      };
    };
  };
}
