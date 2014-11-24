-module(webhooks_hipchat).
-export([
  message_room/1
, message_room/3
, message_room/4
, message_room/5
]).

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
