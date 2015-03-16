%%%-----------------------------------------------------------------------------
%%% @Copyright (C) 2012-2015, Feng Lee <feng@emqtt.io>
%%%
%%% Permission is hereby granted, free of charge, to any person obtaining a copy
%%% of this software and associated documentation files (the "Software"), to deal
%%% in the Software without restriction, including without limitation the rights
%%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%%% copies of the Software, and to permit persons to whom the Software is
%%% furnished to do so, subject to the following conditions:
%%%
%%% The above copyright notice and this permission notice shall be included in all
%%% copies or substantial portions of the Software.
%%%
%%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
%%% SOFTWARE.
%%%-----------------------------------------------------------------------------
%%% @doc
%%% emqttd vm monitor.
%%%
%%% @end
%%%-----------------------------------------------------------------------------

%%TODO: this is a demo module....

-module(esockd_monitor).

-author('feng@emqtt.io').

-behavior(gen_server).

-export([start_link/0]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {ok}).

%%------------------------------------------------------------------------------
%% @doc
%% Start emqttd monitor.
%%
%% @end
%%------------------------------------------------------------------------------
-spec start_link() -> {ok, pid()} | ignore | {error, term()}.
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%%=============================================================================
%%% gen_server callbacks
%%%=============================================================================

init([]) ->
    erlang:system_monitor(self(), [{long_gc, 5000}, {large_heap, 1000000}, busy_port]),
    {ok, #state{}}.

handle_call(Request, _From, State) ->
    error_logger:error_msg("unexpected request: ~p", [Request]),
    {stop, {error, unexpected_request}, State}.

handle_cast(Msg, State) ->
    error_logger:error_msg("unexpected msg: ~p", [Msg]),
    {noreply, State}.

handle_info({monitor, GcPid, long_gc, Info}, State) ->
    error_logger:error_msg("long_gc: gcpid = ~p, ~p ~n ~p", [GcPid, process_info(GcPid, 
		[registered_name, memory, message_queue_len,heap_size,total_heap_size]), Info]),
    {noreply, State};

handle_info({monitor, GcPid, large_heap, Info}, State) ->
    error_logger:error_msg("large_heap: gcpid = ~p,~p ~n ~p", [GcPid, process_info(GcPid, 
		[registered_name, memory, message_queue_len,heap_size,total_heap_size]), Info]),
    {noreply, State};

handle_info({monitor, SusPid, busy_port, Port}, State) ->
    error_logger:error_msg("busy_port: suspid = ~p, port = ~p", [process_info(SusPid, 
		[registered_name, memory, message_queue_len,heap_size,total_heap_size]), Port]),
    {noreply, State};

handle_info(Info, State) ->
    error_logger:error_msg("unexpected info: ~p", [Info]),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


