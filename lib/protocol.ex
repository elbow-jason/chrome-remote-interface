defmodule ChromeRemoteInterface.Protocol do
  require Logger

  alias ChromeRemoteInterface.{
    HTTP,
    Server
  }

  def fetch_protocol() do
    with(
      :error <- try_to_load_from_url(),
      :error <- try_to_load_from_file()
    ) do
      {:error, :protocol_is_misconfigured}
    else
      {:file, file, json} ->
        Logger.info("Fetched protocol.json from file #{inspect(file)}")
        {:ok, file, json}
      {:url, url, json} ->
        Logger.info("Fetched protocol.json from url #{inspect(url)}")
        {:ok, url, json}
    end
  end

  defp try_to_load_from_url() do
    with(
      {:ok, url} <- fetch_config(:url),
      {:ok, json} <- fetch_by_url(url)
    ) do
      {:url, url, json}
    else
      _ -> :error
    end
  end

  defp try_to_load_from_file() do
    with(
      {:ok, file} <- fetch_config(:file),
      {:ok, json} <- fetch_by_filepath(file)
    ) do
      {:file, file, json}
    else
      _ -> :error
    end
  end

  defp fetch_by_url(url) do
    with(
      %URI{host: host, port: port, path: path} <- URI.parse(url),
      server <- %Server{host: host, port: port},
      {:ok, json} <- HTTP.call(server, path),
      {:ok, encoded} <- Poison.encode(json)
    ) do
      {:ok, encoded}
    else
      _ -> {:error, :failed_to_fetch_by_uri}
    end
  end

  defp fetch_by_filepath(filepath) do
    with(
      {:ok, bytes} <- File.read(filepath)
    ) do
      Logger.info("Fetched protocol from file #{inspect(filepath)}")
      {:ok, bytes}
    else
      {:error, _} = err -> err
    end
  end

  defp fetch_config() do
    Application.fetch_env(:chrome_remote_interface, :protocol)
  end

  defp fetch_config(key) do
    with(
      {:ok, config} <- fetch_config(),
      {:ok, value} <- Keyword.fetch(config, key)
    ) do
      {:ok, value}
    else
      _ -> :error
    end
  end
end
