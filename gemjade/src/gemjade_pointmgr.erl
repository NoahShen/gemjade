-module(gemjade_pointmgr).

-author('Noah.Shen87@gmail.com').

-include("gemjade.hrl").

-record(state,
        {dboptions=#dbOptions{}}).

-behaviour(gen_server).

%% External exports
-export([start_link/1]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-export([get_point/1, put_point/1, remove_point/1]).

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
		<<"SELECT id, longitude, latitude, longZone, latZone, X(utmLoc) as easting, Y(utmLoc) as northing, type FROM point WHERE id = ?">>),
	
	mysql:prepare(insert_point_sql,
		<<"INSERT INTO point VALUES(?, ?, ?, ?, ?, GeomFromText(?), ?)">>),
	
	mysql:prepare(update_point_sql,
		<<"UPDATE point set longitude = ?, latitude = ?, longZone = ?, latZone = ?, utmLoc = GeomFromText(?) WHERE id = ?">>),

	mysql:prepare(remove_point_sql,
		<<"DELETE FROM point WHERE id = ?">>),

	process_flag(trap_exit, true),
    {ok, #state{dboptions = Options}}.

handle_call(_Request, _From, State) ->
	Reply = case _Request of
		{get_point, PointId} ->
			do_get_point(PointId);
		{put_point, Point} ->
			do_put_point(Point);
		{remove_point, PointId} ->
			do_remove_point(PointId);
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
	
	AllRows = mysql:get_result_rows(MysqlRes),
	[Id, Lon, Lat, Long_zone, Lat_zone, Easting, Northing, Type] = 
		lists:nth(1, AllRows),
	#point{
		id = binary_to_list(Id),
		lon = Lon,
		lat = Lat,
		long_zone = binary_to_list(Long_zone),
        lat_zone = binary_to_list(Lat_zone),
		easting = Easting,
		northing = Northing,
		type = binary_to_list(Type)}.


put_point(Point) -> 
	gen_server:call(?MODULE, {put_point, Point}).


do_put_point(Point) ->
	case Point#point.type of
		undefined ->
			do_put_point_1(Point);
		_ -> 
			do_put_point_2(Point)
	end.

do_put_point_1(Point) ->
	Point_SQL = io_lib:format("POINT(~s ~s)", 
						  [integer_to_list(Point#point.easting), 
							integer_to_list(Point#point.northing)]),
	
	mysql:execute(p1, update_point_sql, [
		Point#point.lon,
		Point#point.lat,
		Point#point.long_zone,
		Point#point.lat_zone,
		Point_SQL,
		Point#point.id
	]).

do_put_point_2(Point) ->
	Point_SQL = io_lib:format("POINT(~s ~s)", 
						  [integer_to_list(Point#point.easting), 
							integer_to_list(Point#point.northing)]),
	
	Result = mysql:execute(p1, insert_point_sql, [
		Point#point.id,
		Point#point.lon,
		Point#point.lat,
		Point#point.long_zone,
		Point#point.lat_zone,
		Point_SQL,
		Point#point.type
	]),

	case Result of
		{error, _} ->
			do_put_point_1(Point);
		_ ->
			Result
	end.

remove_point(PointId) ->
	gen_server:call(?MODULE, {remove_point, PointId}).


do_remove_point(PointId) ->
	mysql:execute(p1, remove_point_sql, [PointId]).








