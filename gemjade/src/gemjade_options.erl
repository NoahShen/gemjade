%% Author: noah
-module(gemjade_options).
-author('Noah.Shen87@gmail.com').
%%
%% Include files
%%
-include("gemjade.hrl").

%%
%% Exported Functions
%%
-export([parse_dboptions/1]).

%%
%% API Functions
%%
parse_dboptions(Options) ->
	parse_dboptions(Options, #dbOptions{}).

%%
%% Local Functions
%%

parse_dboptions([], State) ->
	{ok, State};

parse_dboptions([{user, U} | Rest], State) when is_list(U) ->
    parse_dboptions(Rest, State#dbOptions{user = U});

parse_dboptions([{password, P} | Rest], State) when is_list(P) ->
    parse_dboptions(Rest, State#dbOptions{password = P});

parse_dboptions([{host, H} | Rest], State) when is_list(H) ->
    parse_dboptions(Rest, State#dbOptions{host = H});

parse_dboptions([{port, Port} | Rest], State) when is_integer(Port) ->
    parse_dboptions(Rest, State#dbOptions{port = Port});

parse_dboptions([{database, D} | Rest], State) when is_list(D) ->
    parse_dboptions(Rest, State#dbOptions{database = D});

parse_dboptions([{encoding, E} | Rest], State) when is_atom(E) ->
    parse_dboptions(Rest, State#dbOptions{encoding = E}).


