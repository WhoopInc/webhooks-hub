-module(webhooks_datadog_event).
-export([
  send_event/1,
  url/0
]).
-include("webhooks_datadog_event.hrl").

get_api_key() ->
  case os:getenv("DATADOG_API_KEY") of
    false ->
      erlang:error(missing_datadog_key);
    Key ->
      Key
  end.

url() ->
  <<"https://app.datadoghq.com/event/stream">>.

send_event(EventRecord) ->
  lager:info("Sending an event to Datadog"),
  JsonOut = jiffy:encode(EventRecord),
  Result = ibrowse:send_req("https://app.datadoghq.com/api/v1/events?api_key="++get_api_key(),
                  [{"Content-Type", "application/json"}],
                  post,
                  JsonOut,
                  [{content_type, "application/json"}]),
  case Result of
    {ok, Status, _Headers, _Body} when Status < 300, Status >= 200 ->
      ok;
    {ok, Status, _Headers, _Body} ->
      Status;
    {ibrowse_req_id, _} ->
      async;
    {error, _Reason} ->
      error
  end.
