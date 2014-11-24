-module(webhooks_docker).
-export([init/3, init/2]).
-export([
  allowed_methods/2
, content_types_provided/2
, content_types_accepted/2
]).
-export([json_in/2]).

-include("webhooks_datadog_event.hrl").

init(Req, Opts) ->
  {cowboy_rest, Req, Opts}.
init(_, _Req, _Opts) ->
  {upgrade, protocol, cowboy_rest}.

allowed_methods(Req, State) ->
  {[<<"POST">>], Req, State}.

content_types_provided(Req, State) ->
  {[
    {<<"application/json">>, to_json}
  ], Req, State}.

content_types_accepted(Req, State) ->
  {[
    {<<"application/json">>, json_in}
  ], Req, State}.

json_in(Req, State) ->
  lager:info("Got a Docker webhook post"),
  {ok, Body, Req2} = cowboy_req:body(Req),
  Parsed = jiffy:decode(Body, [return_maps]),
  #{<<"push_data">> := #{
                          <<"pusher">> := Pusher
                        },
    <<"repository">> := #{
                          <<"repo_name">> := RepoName,
                          <<"repo_url">> := RepoUrl
                         },
    <<"callback_url">> := CallbackUrl
  } = Parsed,
  Event = #{
    <<"title">> => erlang:iolist_to_binary([Pusher, <<" pushed a new image of ">>, RepoName]),
    <<"text">> => RepoUrl,
    <<"alert_type">> => success,
    <<"aggregation_key">> => RepoName,
    <<"source_type_name">> => <<"docker">>
  },
  Result = webhooks_datadog_event:send_event(Event),
  Result2 = webhooks_hipchat:message_room(lists:concat(["A new version of ", binary_to_list(RepoName), " has been pushed. Ready for deploy."])),
  Result3 = Result == Result2,
  perform_callback(CallbackUrl, ok == Result3, <<"Posted to Datadog">>, webhooks_datadog_event:url()),
  {true, Req2, State}.

perform_callback(CallbackUrl, Ok, Description, TargetUrl) ->
  lager:info("Post callback back to Docker Registry"),
  State = case Ok of
    true ->
      <<"success">>;
    _ ->
      <<"error">>
  end,

  JsonOut = jiffy:encode(#{
    <<"state">> => State,
    <<"description">> => Description,
    <<"target_url">> => TargetUrl
  }),
  Result = ibrowse:send_req(binary_to_list(CallbackUrl),
                            [{"Content-Type", "application/json"}],
                            post,
                            JsonOut,
                            [{content_type, "application/json"}]).
