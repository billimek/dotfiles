# Network UPS Tools (NUT) server and monitoring
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.nut;

  # UPS notification script that posts to Discord
  upsNotifyScript = pkgs.writeShellScript "ups-notify.sh" ''
    #!/bin/sh
    HOST=$(${pkgs.nettools}/bin/hostname)
    WEBHOOK_URL=$(cat ${config.services.onepassword-secrets.secretPaths.discordWebhookUrl})

    # UPS event is passed as first argument
    EVENT="$1"

    ${pkgs.curl}/bin/curl -X POST \
      --data-urlencode "payload={\"username\": \"UPS\", \"text\": \":exclamation: UPS Alert on $HOST: $EVENT\", \"icon_emoji\": \":electric_plug:\"}" \
      "$WEBHOOK_URL"
  '';
in
{
  options.modules.nut = {
    enable = lib.mkEnableOption "NUT UPS monitoring and server";

    upsName = lib.mkOption {
      type = lib.types.str;
      default = "ups";
      description = "Name of the UPS device in NUT configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable NUT in netserver mode to allow both local monitoring and remote clients
    power.ups = {
      enable = true;
      mode = "netserver";

      # Configure the UPS hardware
      ups.${cfg.upsName} = {
        driver = "usbhid-ups";
        port = "auto";
        description = "USB-connected UPS";
      };

      # Configure upsd (NUT server) to listen on all interfaces
      upsd = {
        enable = true;
        listen = [
          {
            address = "0.0.0.0";
            port = 3493;
          }
        ];
      };

      # Configure users for NUT server access
      users = {
        # Primary user for local upsmon (has shutdown privileges)
        upsmon = {
          passwordFile = config.services.onepassword-secrets.secretPaths.nutUpsmonPassword;
          upsmon = "primary";
        };
        # Secondary user for remote monitoring clients (read-only)
        monitor = {
          passwordFile = config.services.onepassword-secrets.secretPaths.nutMonitorPassword;
          upsmon = "secondary";
        };
      };

      # Configure upssched for event notifications
      schedulerRules = ''
        CMDSCRIPT ${upsNotifyScript}
        PIPEFN /run/nut/upssched.pipe
        LOCKFN /run/nut/upssched.lock

        # Notify immediately on these events
        AT ONBATT * EXECUTE onbatt
        AT ONLINE * EXECUTE online
        AT LOWBATT * EXECUTE lowbatt
        AT COMMOK * EXECUTE commok
        AT COMMBAD * EXECUTE commbad
        AT SHUTDOWN * EXECUTE shutdown
        AT REPLBATT * EXECUTE replbatt
        AT NOCOMM * EXECUTE nocomm
      '';

      # Configure local upsmon to monitor this UPS
      upsmon = {
        enable = true;
        monitor.${cfg.upsName} = {
          system = "${cfg.upsName}@localhost";
          user = "upsmon";
          type = "primary";
        };
        # Override default settings to ensure upssched is called for all events
        settings = {
          NOTIFYFLAG = [
            [
              "ONLINE"
              "SYSLOG+EXEC"
            ]
            [
              "ONBATT"
              "SYSLOG+EXEC"
            ]
            [
              "LOWBATT"
              "SYSLOG+EXEC"
            ]
            [
              "FSD"
              "SYSLOG+EXEC"
            ]
            [
              "COMMOK"
              "SYSLOG+EXEC"
            ]
            [
              "COMMBAD"
              "SYSLOG+EXEC"
            ]
            [
              "SHUTDOWN"
              "SYSLOG+EXEC"
            ]
            [
              "REPLBATT"
              "SYSLOG+EXEC"
            ]
            [
              "NOCOMM"
              "SYSLOG+EXEC"
            ]
          ];
        };
      };
    };

    # Configure Prometheus NUT exporter for metrics
    services.prometheus.exporters.nut = {
      enable = true;
      port = 9199;
      nutServer = "127.0.0.1";
      # No authentication needed for local exporter access
    };

    # Open firewall ports (for documentation, firewall is disabled on NAS)
    networking.firewall.allowedTCPPorts = [
      3493 # NUT server (upsd)
      9199 # Prometheus NUT exporter
    ];

    # Ensure NUT services wait for 1Password secrets to be available
    systemd.services.upsmon = {
      requires = [ "opnix-secrets.service" ];
      after = [ "opnix-secrets.service" ];
    };

    systemd.services.upsd = {
      requires = [ "opnix-secrets.service" ];
      after = [ "opnix-secrets.service" ];
    };

    # Add NUT utilities to system packages for debugging
    environment.systemPackages = with pkgs; [
      config.power.ups.package # Includes upsc, upscmd, etc.
    ];
  };
}
