-module(gemjade_dbhelper).

-author('Noah.Shen87@gmail.com').

-include("gemjade.hrl").

-record(state,
        {dboptions=#dbOptions{}}).

-behaviour(gen_server).

%% External exports
-export([start_link/1]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-export([get_point/1]).

%% @spec start_link() -> ServerRet
start_link(State) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, State, []).


init(State) ->
	{ok, Options} = gemjade_options:parse_dboptions(State),
	
	mysql:start_link(p1, Options#dbOptions.host, Options#dbOptions.port, 
					 Options#dbOptions.user, Options#dbOptions.password,
					 Options#dbOptions.database, 
					 undefined, 
					 Options#dbOptions.encoding),

    %% Add 2 more connections to the connection pool
    mysql:connect(p1, Options#dbOptions.host, Options#dbOptions.port, 
				  	Options#dbOptions.user, Options#dbOptions.password, 
				  	Options#dbOptions.database,
				  	Options#dbOptions.encoding, true),
    mysql:connect(p1, Options#dbOptions.host, Options#dbOptions.port, 
				  	Options#dbOptions.user, Options#dbOptions.password, 
				  	Options#dbOptions.database,
				  	Options#dbOptions.encoding, true),
	
	mysql:prepare(get_point_sql,
		<<"SELECT * FROM point WHERE id = ?">>),
	
	
	process_flag(trap_exit, true),
    {ok, #state{dboptions = Options}}.

handle_call(_Request, _From, State) ->
	Reply = case _Request of
		{get_point, PointId} ->
			do_get_point(PointId);
		_ ->
			{error, "Bad request"}
	end,

	{reply, Reply, State}.

handle_cast(_Msg, State) ->
	{noreply, State}.

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.
 
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

get_point(PointId) -> 
	gen_server:call(?MODULE, {get_point, PointId}).

do_get_point(PointId) ->
	
	{data, MysqlRes} = mysql:execute(p1, get_point_sql, [list_to_binary(PointId)]),
	
	_AllRows = mysql:get_result_rows(MysqlRes).