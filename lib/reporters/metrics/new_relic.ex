defmodule Extatic.Reporters.Metrics.NewRelic do
  @behaviour Extatic.Behaviours.MetricReporter
  def send(stat_list) do
    send_request(stat_list)
  end

  def build_url(url, api_key) do
    "#{url}?api_key=#{api_key}"
  end



  def send_request(state = %{config: config, metrics: metrics}) when length(metrics) > 0 do
    url = build_url(config.url,config.api_key)
    body = build_request(metrics, config)
    headers = ["Content-Type": "application/json"]
    request_options = options(config)

    HTTPoison.post(url, body, headers, request_options)
  end

  def send_request(state), do: nil

  def build_request(stats, config) do
    now = get_time
    host = config.host
    tags = ""
    list = stats |> Enum.map(fn (s) ->
      %{
        "metric": s.name,
        "points": [
          [now, s.value]
        ],
        "host": host,
        "tags": tags

      }
    end)

    data = %{"series": list}

    {:ok, body} = Poison.encode data
    body
  end

  def get_body(stats) do

    {:ok, json} = Poison.encode(stats)
    json
  end



  def get_time do
    DateTime.utc_now |> DateTime.to_unix
  end



  defp options(%{proxy: %{username: username, password: password, host: host, port: port}}) do
    [
      proxy: "http://#{host}:#{port}",
      proxy_auth: {
        username,
        password
      }
    ]
  end

  defp options(%{proxy: %{host: host, port: port}}) do
    [
      proxy: "http://#{host}:#{port}"
    ]
  end

  defp options(_) do
    []
  end


end
