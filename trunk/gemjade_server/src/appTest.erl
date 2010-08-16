%% Author: noah
%% Created: 2010-8-1
%% Description: TODO: Add description to appTest
-module(appTest).

%%
%% Include files
%%

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
	io:format("Req: ~p~n", [Req]),
%%     error_logger:info_report([helloweb, {req, Req}]),
	Path = Req:get(raw_path),
	io:format("path: ~s~n", [Path]),
	QueryString = Req:parse_post(),
	io:format("post: ~p~n", [QueryString]),
    Req:ok({"text/plain", "hello world"}).





