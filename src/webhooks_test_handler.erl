-module(webhooks_test_handler).
-export([init/3, init/2]).
-export([
  allowed_methods/2
, content_types_provided/2
, content_types_accepted/2
]).
-export([to_json/2, from_json/2]).


init(Req, Opts) ->
  {cowboy_rest, Req, Opts}.
init(_, _Req, _Opts) ->
  {upgrade, protocol, cowboy_rest}.

allowed_methods(Req, State) ->
  {[<<"POST">>], Req, State}.

content_types_provided(Req, State) ->
  io:format("content_types_provided~n"),
  {[
    {<<"application/json">>, to_json}
  ], Req, State}.

content_types_accepted(Req, State) ->
  io:format("content_types_accepted~n"),
  {[
    {<<"application/json">>, from_json}
  ], Req, State}.

to_json(Req, State) ->
  io:format("to_json~n"),
  {<<"{\"foo\":\"bar\"}">>, Req, State}.

from_json(Req, State) ->
  io:format("from_json(~p,~p)~n", [Req,State]),
  {true, Req, State}.
