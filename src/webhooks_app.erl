-module(webhooks_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    lager:start(),
    Routes = [
	      {"/docker", webhooks_docker, []}
	     ,{"/hipchat", webhooks_hipchat, []}
	     ],
    Dispatch = cowboy_router:compile([
				      {'_', Routes}
				     ]),
    cowboy:start_http(my_http_listener, 100,
		      [{port, 80}],
		      [{env, [{dispatch, Dispatch}]}]
		     ),
    lager:info("Starting with routes ~p", [Routes]),
    webhooks_sup:start_link().

stop(_State) ->
    ok.
