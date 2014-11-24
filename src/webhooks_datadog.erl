-module(webhooks_datadog).
-export([
  init/1,
  send_event/1
]).
-include_lib("webmachine/include/webmachine.hrl").
-include("webhooks_datadog.hrl").

init(Config) ->
  io:format("init(~p)~n", [Config]),
  {true, Config}.

get_api_key() ->
  os:getenv("DATADOG_API_KEY").

send_event(EventRecord) ->
  ibrowse:send_req("https://app.datadoghq.com/api/v1/events?api_key="++get_api_key(),
                  [],
                  post,
                  datadog_event:to_json(EventRecord),
                  [{content_type, "application/json"}]).
