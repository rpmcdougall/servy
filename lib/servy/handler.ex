defmodule Servy.Handler do
  require Logger

  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  def log(conv) do
    Logger.info(inspect(conv))
    conv
  end

  def track(%{status: 404, path: path} = conv) do
    Logger.warn "Warning: #{path} not available."
    conv
  end

  def track(conv), do: conv

  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(conv), do: conv

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first
      |> String.split(" ")
    %{method: method,
      path: path,
      resp_body: " ",
      status: nil
    }
  end

  # def route(conv) do
  #   route(conv, conv.method, conv.path)
  # end

  def route(%{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%{method: "GET", path: "/bears"} = conv) do
    %{conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  def route(%{method: "GET", path: "/bears" <> id} = conv) do
    %{conv | status: 200, resp_body: "Bear #{id}"}
  end

  ## Exercise Implement Delete
  def route(%{method: "DELETE", path: "/bears" <> _id} = conv) do
    %{conv | status: 204, resp_body: " "}
  end

  def route(%{path: path} = conv) do
    %{conv | status: 404, resp_body: "No #{path} here!"}
  end

  def format_response(conv) do
    #TODO Use values in map to create and HTTP resposne string
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      204 => "No Content",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end

end

request =
  """
  GET /wildthings HTTP/1.1
  Host: example.com
  User-Agent:ExampleBrowser/1.0
  Accept:*/*
  """


  response = Servy.Handler.handle(request)
  IO.puts response

  bears  =
    """
    GET /bears HTTP/1.1
    Host: example.com
    User-Agent:ExampleBrowser/1.0
    Accept:*/*
    """


    response = Servy.Handler.handle(bears)
    IO.puts response

    bigfoot  =
      """
      GET /bigfoot HTTP/1.1
      Host: example.com
      User-Agent:ExampleBrowser/1.0
      Accept:*/*
      """


      response = Servy.Handler.handle(bigfoot)
      IO.puts response

      bears1  =
        """
        GET /bears/1 HTTP/1.1
        Host: example.com
        User-Agent:ExampleBrowser/1.0
        Accept:*/*
        """


        response = Servy.Handler.handle(bears1)
        IO.puts response

        delete  =
          """
          DELETE /bears/1 HTTP/1.1
          Host: example.com
          User-Agent:ExampleBrowser/1.0
          Accept:*/*
          """


          response = Servy.Handler.handle(delete)
          IO.puts response
