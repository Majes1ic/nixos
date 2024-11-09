{ lib, config, ... }:
let
  inherit (lib)
    mkOption
    types
    optionalAttrs
    genAttrs
    hasPrefix
    attrNames
    filter
    ;
in
{
  options.networking.firewall.defaultInterfaces = mkOption {
    type = with types; listOf str;
    default = [ ];
    example = [ "eno1" ];
    description = ''
      If set, networking.firewall.allowed* options are exclusively applied to
      these interfaces. Otherwise, networking.firewall.allowed* options apply
      to all interfaces.
    '';
  };

  config.networking.firewall.allInterfaces =
    let
      cfg = config.networking.firewall;
      commonOptions = filter (x: hasPrefix "allowed" x) (attrNames config.networking.firewall);

      defaultInterface = optionalAttrs (cfg.defaultInterfaces == [ ]) {
        default = genAttrs commonOptions (option: cfg.${option});
      };

      defaultInterfaces = genAttrs cfg.defaultInterfaces (
        interface:
        genAttrs commonOptions (
          option:
          cfg.${option}
          # Merge will override cfg.interfaces options so concat lists
          ++ cfg.interfaces.${interface}.${option} or [ ]
        )
      );
    in
    defaultInterface // cfg.interfaces // defaultInterfaces;
}
