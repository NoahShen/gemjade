%% file: mysql_test.erl
%% author: Yariv Sadan (yarivvv@gmail.com)
%% for license see COPYING

-module(gemjade_test).

-include("gemjade.hrl").

-compile(export_all).

start() ->    
    gemjade_dbhelper:start_link([
		{host, "localhost"},
		{port, 3306},
		{database, "gemjade"},
		{user, "root"},
		{password, "123456"},
		{encoding, utf8}]),
    	
    ok.
    
get_point() ->
	start(),
	gemjade_dbhelper:get_point("123").

put_point() ->
	start(),
	gemjade_dbhelper:put_point(#point{
									id = "1234",
									lon = 121.443297,
									lat = 31.221891,
									long_zone = "51",
         							lat_zone = "R",
		 							easting = 351724,
		 							northing = 3455237}).
