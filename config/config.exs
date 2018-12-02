use Mix.Config

config :chrome_remote_interface, :protocol,
  file: "priv/protocol.json",
  url: "http://localhost:9222/json/protocol"
