% Pietro Paolini - Birkbeck University
% Programming Paradigms 2015/2016 Concurrent programming coursework
-module(test).
-export([start/0, 
	 stop/0,
	 insert/2,
	 remove/1,
	 lookup/1
	]).

start() ->
    Pid = spawn (fun() -> startloop() end),
    register(dictionary, Pid).
    
stop() ->
    exit(whereis(dictionary), ok).

insert(Key, Value) ->
    dictionary ! {self(), {insert, Key, Value}}.

remove(Key) ->
    dictionary ! {self(), {remove, Key}}.

lookup(Key) ->
    dictionary ! {self(), {lookup, Key}},
    receive
	Response -> Response
    end.

startloop() ->
    TableId = ets:new(dictionary, [set]),
    loop(TableId).
    
loop(Table) ->
    receive
	{From, {insert, Key, Value}} ->
	    From ! ets:insert(Table, {Key, Value}),
	    loop(Table);
	{From, {lookup, Key}} ->
	    From ! ets:lookup(Table, Key),
	    loop(Table);
	{From, Any} ->
	    From ! {self(), {error,Any}},
	    loop(Table)
    end.
