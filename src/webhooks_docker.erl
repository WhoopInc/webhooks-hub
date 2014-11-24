-module(webhooks_docker).
-export([
  init/1,
  allowed_methods/2,
  process_post/2
]).
-include_lib("webmachine/include/webmachine.hrl").
-record(docker_pd_rec, {
  pushed_at,
  images,
  pusher
}).
-record(docker_rep_rec, {
  status,
  description,
  is_trusted,
  full_description,
  repo_url,
  owner,
  is_official,
  is_private,
  name,
  namespace,
  star_count,
  comment_count,
  date_created,
  dockerfile,
  repo_name
}).
-record(docker_rec, {
  push_data :: #docker_pd_rec{},
  repository :: #docker_rep_rec{}
}).

init(Config) ->
  io:format("init(~p)~n", [Config]),
  {true, Config}.

allowed_methods(Req, State) ->
  {['POST'], Req, State}.

process_post(Req, State) ->
  %JsonIn = jiffy:decode(wrq:req_body(Req), [return_maps]),
  io:format("JSON=~p~n", [wrq:req_body(Req)]),
  %Out = docker_rec:from_json(wrq:req_body(Req)),
  %io:format("Rec=~p~n", [Out]),
  {true, Req, State}.
