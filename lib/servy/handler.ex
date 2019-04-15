defmodule Servy.Handler do
  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]

  alias Servy.Conv

  @pages_path Path.expand("pages", File.cwd!())
  @moduledoc "Handles HTTP Requests."

  @doc "Transforms the request into a response."
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  ## Multi-clause functions vs case ##
  def handle_file({:ok, content}, conv) do
    %Conv{conv | status: 200, resp_body: content}
  end

  def handle_file({:error, :enoent}, conv) do
    %Conv{conv | status: 404, resp_body: "File not found!"}
  end

  def handle_file({:error, reason}, conv) do
    %Conv{conv | status: 500, resp_body: "File error: #{reason}"}
  end

  # case File.read(file) do
  #   {:ok, content} ->
  #     %Conv{conv | status: 200, resp_body: content}
  #   {:error, :enoent} ->
  #     %Conv{conv | status: 404, resp_body: "File not found!"}
  #   {:error, reason} ->
  #     %Conv{conv | status: 500, resp_body: "File error: #{reason}"}
  # end

  ############################################

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %Conv{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    %Conv{conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conv)
  end

  # Exercise,serve a form
  def route(%Conv{method: "GET", path: "/bears/new"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read()
    |> handle_file(conv)
  end

  # Exercise serve arbirtary pages

  def route(%Conv{method: "GET", path: "/bears" <> id} = conv) do
    %Conv{conv | status: 200, resp_body: "Bear #{id}"}
  end

  # Exercise serve arbirtary pages

  def route(%Conv{method: "GET", path: "/pages/" <> file} = conv) do
    file = Path.join(@pages_path, file <> ".html")

    case File.read(file) do
      {:ok, content} ->
        %Conv{conv | status: 200, resp_body: content}

      {:error, :enoent} ->
        %Conv{conv | status: 404, resp_body: "File not found!"}

      {:error, reason} ->
        %Conv{conv | status: 500, resp_body: "File error: #{reason}"}
    end
  end

  ## Exercise Implement Delete
  def route(%Conv{method: "DELETE", path: "/bears" <> _id} = conv) do
    %Conv{conv | status: 204, resp_body: " "}
  end

  # name=Balooo&type=Brown
  def route(%Conv{method: "POST", path: "/bears" <> _id} = conv) do
    %Conv{conv | status: 201, params: conv.params, resp_body: "Created #{conv.params["type"]} bear named #{conv.params["name"]}"}
  end

  def route(%Conv{path: path} = conv) do
    %Conv{conv | status: 404, resp_body: "No #{path} here!"}
  end

  def format_response(%Conv{} = conv) do
    # TODO Use values in map to create and HTTP resposne string
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}
    """
  end
end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*


"""

response = Servy.Handler.handle(request)
IO.puts(response)

bears = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*


"""

response = Servy.Handler.handle(bears)
IO.puts(response)

bigfoot = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*


"""

response = Servy.Handler.handle(bigfoot)
IO.puts(response)

bears1 = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*


"""

response = Servy.Handler.handle(bears1)
IO.puts(response)

delete = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*


"""

response = Servy.Handler.handle(delete)
IO.puts(response)

static = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*


"""

response = Servy.Handler.handle(static)
IO.puts(response)

post = """
POST /bears HTTP/1.1
Host: example.com
Content-Type: application/x-www-form-urlencoded
User-Agent: ExampleBrowser/1.0
Content-Length: 21
Accept: */*

name=Balooo&type=Brown
"""

response = Servy.Handler.handle(post)
IO.puts(response)
