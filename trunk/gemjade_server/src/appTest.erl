%% Author: noah
%% Created: 2010-8-1
%% Description: TODO: Add description to appTest
-module(appTest).

%%
%% Include files
%%
-include("gemjade_server.hrl").

%%
%% Exported Functions
%%
-export([start/0, 
		 stop/0,
		 dispatch/1]).

%%
%% API Functions
%%
start() ->
    mochiweb_http:start([
        {name, ?MODULE},
        {ip, any},
        {port, 8080},
        {loop, {?MODULE, dispatch}}
    ]).
stop() ->
    mochiweb:stop(?MODULE).


%%
%% Local Functions
%%

dispatch(Req) ->
%% 	io:format("Req: ~p~n", [Req]),
%% 	error_logger:info_report([helloweb, {req, Req}]),
	Path = Req:get(path),
	Tokens = string:tokens(Path, "/"),
	io:format("path: ~s~n", [lists:nth(1, Tokens)]),
	
	case lists:nth(1, Tokens) of
		"subscribe" -> 
			handle_request(Req);
		_ -> 
			Req:respond({400, 
						[{"Content-Type", "text/plain"}],
						<<"Bad path">>})
	end.

    
handle_request(Req) ->
	Post = Req:parse_post(),
	case Post of
		[] ->
			Req:respond({400, 
						[{"Content-Type", "text/plain"}],
						<<"Empty post parameters">>});
		_ ->
			case parse_sub_request(Post) of
				{ok, Sub_request = #sub_request{action = Action}} ->
					case Action of
						"subscribe" ->
							handle_subscribe(Req, Sub_request);
						"unsubscribe" ->
							handle_unsubscribe(Req, Sub_request)
					end;
				{error, Reason} ->
					Req:respond({400, 
						[{"Content-Type", "text/plain"}],
						list_to_binary(Reason)})
			end
			
	end.


parse_sub_request(Post) ->
	parse_sub_request(Post, #sub_request{}).

parse_sub_request([], _Sub_request=#sub_request{action = Action,
												node = Node,
												callback = Callback,
												verify_token = Verify_token}) 
  												when Action == undefined
  												orelse Node == undefined
  												orelse Callback == undefined
  												orelse Verify_token == undefined
  												->
	{error, "Bad sub request"};

parse_sub_request([], Sub_request) ->
	{ok, Sub_request};

parse_sub_request([{"gemjade.action", Action} | T], Sub_request) ->
	if 
		Action == "subscribe" orelse Action == "unsubscribe" ->
			parse_sub_request(T, Sub_request#sub_request{action = Action});
		true ->
			{error, "Bad Action"}
	end;
	
	
parse_sub_request([{"gemjade.node", Node} | T], Sub_request) ->
	parse_sub_request(T, Sub_request#sub_request{node = Node});

parse_sub_request([{"gemjade.callback", Callback} | T], Sub_request) ->
	parse_sub_request(T, Sub_request#sub_request{callback = Callback});

parse_sub_request([{"gemjade.verify_token", Verify_token} | T], Sub_request) ->
	parse_sub_request(T, Sub_request#sub_request{verify_token = Verify_token});

parse_sub_request([{_, _} | T], Sub_request) ->
	parse_sub_request(T, Sub_request).


handle_subscribe(Req, Sub_Request) ->
	Req:ok({"text/plain", "handle_subscribe"}).

handle_unsubscribe(Req, Sub_Request) ->
	Req:ok({"text/plain", "handle_unsubscribe"}).