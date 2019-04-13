defmodule Servy.Plugins do
  require Logger

  alias Servy.Conv

  def log(conv) do
    Logger.info(inspect(conv))
    conv
  end

  @doc "Logs 404 requests."
  def track(%Conv{status: 404, path: path} = conv) do
    Logger.warn "Warning: #{path} not available."
    conv
  end

  def track(%Conv{} = conv), do: conv

  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %Conv{conv | path: "/wildthings"}
  end

  def rewrite_path(%Conv{} = conv), do: conv
end
