-module(test).
-export([start/0, interact/2]).

start() ->
    spawn (fun() -> startloop() end).
    
interact(Pid, Request) ->
    Pid ! {self(), Request},
    receive 
	Response -> Response
    end.

startloop() ->
    TableId = ets:new(dictionary, [set]),
    loop(TableId).
    
loop(Table) ->
    receive
	{From, {insert, Key, Value}} ->
	    io:format("Here insert"),
	    %TabList = ets:tab2list(Table),
	    %lists:map(fun(X) -> io:format("Item : ~s", [X]) end, TabList),
	    Return = ets:insert(Table, {Key, Value}),
	    From ! Return,
	    loop(Table);
	{From, {lookup, Key}} ->
	    io:format("Here lookup"),
	    Return = ets:lookup(Table, Key),
	    From ! Return,
	    loop(Table);
	{From, Any} ->
	    From ! {self(), {error,Any}},
	    loop(Table)
    end.
