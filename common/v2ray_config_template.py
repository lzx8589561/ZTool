conf_template = {
  "inbounds": [{
        "port": 1080,
        "listen": "127.0.0.1",
        "protocol": "socks",
        "settings": {
            "auth": "noauth",
            "udp": True,
            "userLevel": 8
        },
        "sniffing": {
            "destOverride": [
                "http",
                "tls"
            ],
            "enabled": True
        },
        "tag": "socks"
    }
  ],
  "log": {
        "access": "",
        "error": "",
        "loglevel": "warning"
  },
  "outbounds": [{
          "mux": {
              "enabled": True
          },
          "protocol": "",
          "settings": {},
          "streamSettings": {},
          "tag": "proxy"
      },
      {
          "protocol": "freedom",
          "settings": {},
          "tag": "direct"
      },
      {
          "protocol": "blackhole",
          "settings": {
              "response": {
                  "type": "http"
              }
          },
          "tag": "block"
      }
  ],
  "policy": {
      "levels": {
          "8": {
              "connIdle": 300,
              "downlinkOnly": 1,
              "handshake": 4,
              "uplinkOnly": 1
          }
      },
      "system": {
          "statsInboundUplink": True,
          "statsInboundDownlink": True
      }
  },
  "dns": {},
  "routing": {
      "domainStrategy": "IPOnDemand",
      "rules": []
  },
  "stats": {}
}
