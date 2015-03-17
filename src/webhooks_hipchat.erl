-module(webhooks_hipchat).

%% Sending messages
-export([
  message_room/1
, message_room/3
, message_room/4
, message_room/5
]).

%% Getting webhooks
-export([init/3, init/2]).
-export([
  allowed_methods/2
, content_types_provided/2
, content_types_accepted/2
]).
-export([json_in/2]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Webhooks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
init(Req, Opts) ->
    {cowboy_rest, Req, Opts}.
init(_, _Req, _Opts) ->
    {upgrade, protocol, cowboy_rest}.

allowed_methods(Req, State) ->
    {[<<"POST">>], Req, State}.

content_types_accepted(Req, State) ->
    {[
      {<<"application/json">>, json_in}
     ], Req, State}.

-spec extract_sender(binary()) -> string().
extract_message_parts(JsonBinary) ->
    Parsed = jiffy:decode(JsonBinary, [return_maps]),
    #{<<"item">> := #{
	  <<"message">> := #{
	      <<"from">> := #{
		  <<"name">> := FromName
		 },
	      <<"message">> := Message
	     },
	  <<"room">> := #{
	      <<"name">> := RoomName
	     }
	 }
     } = Parsed,
    {FromName, RoomName, Message}.

json_in(Req, State) ->
    lager:info("Got a Hipchat webhook post"),
    {ok, Body, Req2} = cowboy_req:body(Req),
    {FromName, RoomName, Message} = extract_sender(Body),
    OutMessage = io_lib:format("_Message to ~w:_ ~w", [RoomName, Message]),
    OutSender = io_lib:format("Hipchat/~w", [FromName]),
    webhooks_slack:send_message(OutSender, OutMessage).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Message-sending
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_auth_token() ->
  case os:getenv("HIPCHAT_AUTH_TOKEN") of
    false ->
      erlang:error(missing_hipchat_key);
    Key ->
      Key
  end.

get_room() ->
  case os:getenv("HIPCHAT_ROOM") of
    false ->
      erlang:error(missing_hipchat_room);
    Key ->
      Key
  end.

get_sender() ->
  case os:getenv("HIPCHAT_SENDER_NAME") of
    false ->
      erlang:error(missing_hipchat_sender);
    Key ->
      Key
  end.


message_room(Message) ->
  message_room(get_room(), get_sender(), Message).
message_room(RoomId, From, Message) ->
  message_room(RoomId, From, Message, green).
message_room(RoomId, From, Message, Color) ->
  message_room(RoomId, From, Message, Color, get_auth_token()).
message_room(RoomId, From, Message, Color, Token) ->
  FormData = ["auth_token=", Token,
              "&room_id=", ibrowse_lib:url_encode(RoomId),
              "&from=", ibrowse_lib:url_encode(From),
              "&message=", ibrowse_lib:url_encode(Message),
              "&color=", atom_to_list(Color),
              "&notify=1"],
  Result = ibrowse:send_req("https://api.hipchat.com/v1/rooms/message",
                  [{"Content-Type", "application/x-www-form-urlencoded"}],
                  post,
                  erlang:iolist_to_binary(FormData)),
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
