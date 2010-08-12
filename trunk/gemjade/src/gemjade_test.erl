%% file: mysql_test.erl
%% author: Yariv Sadan (yarivvv@gmail.com)
%% for license see COPYING

-module(gemjade_test).
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
	gemjade_dbhelper:get_point("123").
