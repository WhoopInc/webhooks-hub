%%% @copyright (C) 2015, WHOOP
%%% @doc
%%%
%%% @end
%%% Created : 17 Mar 2015 by Nathaniel Waisbrot <waisbrot@whoop.com>
-module(webhooks_slack).
-author('waisbrot@whoop.com').

-export([
	 send_message/2
	]).

-spec send_message(string(), string()) -> ok.
send_message(Sender, Message) ->
    Json = jiffy:encode(#{
			   <<"text">> => Message,
			   <<"username">> => Sender
			 })
    Result = ibrowse:send_req(get_url(),
			      [{"Content-Type", "application/json"}],
			      post,
			      Json),
  case Result of
      {ok, Status, _Headers, _Body} when Status < 300, Status >= 200 ->
	  ok;
      {ok, Status, _Headers, Body} ->
	  lager:error("Non-200 response from Slack: ~p: ~p", [Status, Body]);
      {error, Reason} ->
	  lager:error("Error posting to Slack: ~p", [Reason])
  end.

get_url() ->
    case os:getenv("SLACK_HOOK_URL") of
	false ->
	    erlang:error(missing_slack_url);
	Key ->
	    Key
    end.
