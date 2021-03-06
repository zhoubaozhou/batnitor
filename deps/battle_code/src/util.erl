%%%-----------------------------------
%%% @Module  : util
%%% @Author  : xyao
%%% @Email   : jiexiaowen@gmail.com
%%% @Created : 2010.04.15
%%% @Description: 公共函数
%%%-----------------------------------
-module(util).
-include("common.hrl").

-export([
%%         log/5,
        unixtime/0,
        longunixtime/0,
        md5/1,
        rand/2,
		ceil/1,
		ceil_div/2,
        floor/1,
        sleep/1,
        sleep/2,
        get_list/2,
        implode/2,
        implode/3,
        explode/2,
        explode/3,
        for/3,
        for/4,
        string_to_term/1,
        bitstring_to_term/1,
        term_to_string/1,
        term_to_bitstring/1,
        is_process_alive/1,
        abs/1,
		distance/4,
		int_untokens/2,
		int_tokens/2,
		list_add/2,
		list_mis/2,
		list_multiple/2,
		max/2,
		min/2,
		get_sys_begin_time/0,
		split/1,
		string_to_binary/1,
		get_page/3,
		get_showlist/3,
		get_eff_list/1,	
		find_bit/2,
		replace_bit/3,
		get_base_hours/0,
		oclock/2,
		check_distance/5,
		get_format_ip/1,
		test_time/0,
		check_other_day/1,
		check_other_day/2,
		get_diff_day/2,
		get_diff_day/3,
		get_diff_time/0,
		get_daily_value/3,
		get_daily_value/4,
		check_command/1, reset_check_command/0,
		get_app_env/1, get_log_app_env/1,
		string_width/1,
		get_rand_list_elems/2,
        randomize/1,
        schedule_timer/3,
        cancel_timer/1,
        get_daily_event_timeout/1,
        get_daily_event_timeout/2,
        deep_list_foldl/3,
        timer_apply_after/4,
        timer_send_after/2,
        erlang_send_after/3,
        cancel_all_timer/0,
        cancel_timer_by_name/2,
        is_in_list/2,
        rand/3,
        check_and_set_cd/3,
        clear_cd/2,
        g_2_unix_second/1,
        u_2_gregorian_second/1,
        u_2_week/1,
        is_diff_week/1,
		get_list_index/2,
		record_add/2,
		record_merge/2,
        record_multiple/2,
		caculate_attri/5,
		caculate_attri2/5,
		one_time_cultivation/8,
		get_next_level/3,
		get_next_levelingId/3,
        get_time_2_activty_end/1,	
		get_rand_list_element/1
    ]).

get_time_2_activty_end(Day) ->
    Now_time = calendar:local_time(), 
    Now_second = calendar:datetime_to_gregorian_seconds(Now_time),
    {Start_Y,Start_M,Start_D} = util:get_app_env(server_first_run),
    Start_second = calendar:datetime_to_gregorian_seconds({{Start_Y,Start_M,Start_D },{0,0,0}}),
    Start_second - Now_second + ?SECONDS_PER_DAY * Day + unixtime().

%% 格里尼治时间戳转unix时间戳
g_2_unix_second(G) ->
    G_Second = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
    G_Second + unixtime() - G.

%% unix时间戳转格里尼治时间戳
u_2_gregorian_second(U) ->
    G_Second = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
    G_Second - unixtime() + U.

%% unix时间戳转{年,周}
u_2_week(U) ->
    Seconds = u_2_gregorian_second(U),
    {Date,_Time} = calendar:gregorian_seconds_to_datetime(Seconds),
    calendar:iso_week_number(Date).

%% 是否是不同一周
is_diff_week(Unix_timestamp) ->
    u_2_week(Unix_timestamp) /= calendar:iso_week_number().

timer_apply_after(TimeToWait, Mod, Fun, Args) ->
	case timer:apply_after(TimeToWait, Mod, Fun, Args) of
	{ok, Ref} ->
		process_put_ref({timer, {Mod, Fun, Args}, Ref});
	_ ->
		false
	end.
	
timer_send_after(TimeToWait, Msg) ->
	case timer:send_after(TimeToWait, Msg) of
	{ok, Ref} ->
		process_put_ref({timer, Msg, Ref});
	_ ->
		false
	end.
	
erlang_send_after(TimeToWait, Dest, Msg) ->
	Ref = erlang:send_after(TimeToWait, Dest, Msg),
	process_put_ref({erlang, Msg, Ref}).
	
process_put_ref(Ref) ->
	RefList = get_all_ref(),
	put(all_timer_ref_in_process, [Ref|RefList]),
	ok.
	
get_all_ref() ->
	case get(all_timer_ref_in_process) of
	undefined ->
		[];
	RefList ->
		RefList
	end.
	
cancel_all_timer() ->
	[rm_timer(Timer) || Timer <- get_all_ref()].
	
cancel_timer_by_name(Type, Name) ->
	F = 
	fun({TimerType, TimerName, TimerRef}, TimerList) ->
		case Type =:= TimerType andalso Name =:= TimerName of
		true ->
			rm_timer({TimerType, TimerName, TimerRef}),
			TimerList;
		false ->
			[{TimerType, TimerName, TimerRef}|TimerList]
		end
	end,
	RestTimerList = lists:foldl(F, [], get_all_ref()),
	put(all_timer_ref_in_process, RestTimerList).
	
rm_timer(Timer) ->
	case Timer of
	{timer, _Name, Ref} ->
		timer:cancel(Ref);
	{erlang, _Name, Ref} ->
		erlang:cancel_timer(Ref)
	end.

%% 在List中的每两个元素之间插入一个分隔符
implode(_S, [])->
	[<<>>];
implode(S, L) when is_list(L) ->
    implode(S, L, []).
implode(_S, [H], NList) ->
    lists:reverse([thing_to_list(H) | NList]);
implode(S, [H | T], NList) ->
    L = [thing_to_list(H) | NList],
    implode(S, T, [S | L]).

%% 字符->列
explode(S, B)->
    re:split(B, S, [{return, list}]).
explode(S, B, int) ->
    [list_to_integer(Str) || Str <- explode(S, B), length(Str) > 0].

thing_to_list(X) when is_integer(X) -> integer_to_list(X);
thing_to_list(X) when is_float(X)   -> float_to_list(X);
thing_to_list(X) when is_atom(X)    -> atom_to_list(X);
thing_to_list(X) when is_binary(X)  -> binary_to_list(X);
thing_to_list(X) when is_list(X)    -> X.

%% %% 日志记录函数
%% log(T, F, A, Mod, Line) ->
%%     {ok, Fl} = file:open("E:/test_log/error_log.txt", [write, append]),
%%     Format = list_to_binary("#" ++ T ++" ~s[~w:~w] " ++ F ++ "\r\n"),
%%     {{Y, M, D},{H, I, S}} = erlang:localtime(),
%%     Date = list_to_binary([integer_to_list(Y),"-", integer_to_list(M), "-", integer_to_list(D), " ", integer_to_list(H), ":", integer_to_list(I), ":", integer_to_list(S)]),
%%     %%?INFO(print,Fl, unicode:characters_to_list(Format), [Date, Mod, Line] ++ A),
%%     file:close(Fl).    

%% 取得当前的unix时间戳
unixtime() ->
    {M, S, _} = erlang:now(),
    M * 1000000 + S.

longunixtime() ->
    {M, S, Ms} = erlang:now(),
    M * 1000000000 + S*1000 + Ms div 1000.
    
%% 当天对应时间的时间戳
%% 可拓展
today_unixtime(H, M, S) ->
	NowTimeStamp = unixtime(),
	{H1, M1, S1} = erlang:time(), 
	NowTime = H1*?SECONDS_PER_HOUR + M1*?SECONDS_PER_MINUTE + S1,
	TargetTime = H*?SECONDS_PER_HOUR + M*?SECONDS_PER_MINUTE + S,
	NowTimeStamp - NowTime + TargetTime.

is_server_first_run() ->
	{{Year,Month,Day},_} = calendar:local_time(),
	{Start_Y,Start_M,Start_D} = util:get_app_env(server_first_run),
	Year =:= Start_Y andalso Month =:= Start_M andalso Day =:= Start_D.

%% 转换成HEX格式的md5
md5(S) ->
    lists:flatten([io_lib:format("~2.16.0b",[N]) || N <- binary_to_list(erlang:md5(S))]).

%% 产生一个介于Min到Max之间的随机整数,[Min, Max]
rand(Same, Same) -> Same;
rand(Min, Max) ->
    %% 如果没有种子，将从核心服务器中去获取一个种子，以保证不同进程都可取得不同的种子
    case get("rand_seed") of
        undefined ->
            RandSeed = mod_rand:get_seed(),
            random:seed(RandSeed),
            put("rand_seed", RandSeed);
        _ -> skip
    end,
    %% random:seed(erlang:now()),
    M = Min - 1,
    random:uniform(Max - M) + M.
    
%% 从一个范围内随机取出N个数
rand(Min, Max, N) ->
	case Max - Min < N of
	true ->
		lists:seq(Min, Max);
	false ->
		rand(Min, Max, N, [])
	end.
	
rand(_Min, _Max, 0, Res) ->
	Res;
rand(Min, Max, N, Res) ->
	Val = rand(Min, Max),
	case is_in_list(Res, Val) of
	true ->
		rand(Min, Max, N, Res);
	false ->
		rand(Min, Max, N - 1, [Val|Res])
	end.
	
is_in_list(List, Ele) ->
	Res = [E || E <- List, E =:= Ele],
	length(Res) > 0.

%% 从一个随机列表（[{Ele1, Rand1}, {Ele2, Rand2}, ...]）中随机取出一个元素
get_rand_list_element(List) ->
	F = fun({_E, R}, S) ->
			S + R
		end,
	MaxRand = lists:foldl(F, 0, List),
	Rand = util:rand(1, MaxRand),
	get_element(List, Rand).

get_element([{Ele, R}|Rest], Rand) ->
	case Rand > R of
		true ->
			get_element(Rest, Rand - R);
		false ->
			Ele
	end.

%%向上取整
ceil(N) ->
    T = trunc(N),
    case N == T of
        true  -> T;
        false -> 1 + T
    end.

%% 对A除以B的商向上取整
ceil_div(A, B) ->
	C = A div B,
	case A rem B == 0 of
		true -> C;
		false -> C + 1
	end.
	
%%向下取整
floor(X) ->
    T = trunc(X),
    case (X < T) of
        true -> T - 1;
        _ -> T
    end.

 sleep(T) ->
    receive
    after T -> ok
    end.

 sleep(T, F) ->
    receive
    after T -> F()
    end.

get_list([], _) ->
    [];
get_list(X, F) ->
    F(X).

%% for循环
for(Max, Max, F) ->
    F(Max);
for(I, Max, F)   ->
    F(I),
    for(I+1, Max, F).

%% 带返回状态的for循环
%% @return {ok, State}
for(Max, Min, _F, State) when Min<Max -> {ok, State};
for(Max, Max, F, State) -> F(Max, State);
for(I, Max, F, State)   -> {ok, NewState} = F(I, State), for(I+1, Max, F, NewState).

%% term序列化，term转换为string格式，e.g., [{a},1] => "[{a},1]"
term_to_string(Term) ->
    %%binary_to_list(list_to_binary(io_lib:format("~w", [Term]))).
	%%use a more effecional way
	lists:flatten(io_lib:format("~w", [Term])).

%% term序列化，term转换为bitstring格式，e.g., [{a},1] => <<"[{a},1]">>
term_to_bitstring(Term) ->
    erlang:list_to_bitstring(io_lib:format("~w", [Term])).

%% term反序列化，string转换为term，e.g., "[{a},1]"  => [{a},1]
string_to_term(String) ->
    case erl_scan:string(String++".") of
        {ok, Tokens, _} ->
            case erl_parse:parse_term(Tokens) of
                {ok, Term} -> Term;
                _Err -> undefined
            end;
        _Error ->
            undefined
    end.

%% term反序列化，bitstring转换为term，e.g., <<"[{a},1]">>  => [{a},1]
bitstring_to_term(undefined) -> undefined;
bitstring_to_term(BitString) ->
    string_to_term(binary_to_list(BitString)).
    
    
%%=============================================================
%% code below was add by dizengrong@gmail.com at 2011-8-7
%%=============================================================
%% 全局分布式进程检查器
is_process_alive(Pid) 
	when is_pid(Pid) ->
    	rpc:call(node(Pid), erlang, is_process_alive, [Pid]).
    	

abs(N) ->
	erlang:abs(N).
%% 	case N >= 0 of
%% 		true -> N;
%% 		false -> -N
%% 	end.

%% 计算坐标(X1, Y1) 与 (X2, Y2)的距离
distance(X1, Y1, X2, Y2) ->
	math:sqrt((X1 - X2)*(X1 - X2) + (Y1 - Y2)*(Y1 - Y2)).

%% 将一整数列表按分割服打包为一个字符串，如[1,2,3]，用"|"来分割打包的话就是"1|2|3"
%% [1]打包则为"1"，[]打包则为""，即为空[]
int_untokens(IntList, Separator) ->
	Size = length(IntList),
	int_untokens_help(Size, IntList, Separator).

int_untokens_help(0, [], _Separator) -> "";
int_untokens_help(1, [Int], _Separator) -> integer_to_list(Int);
int_untokens_help(Size, [Int | Rest], Separator) ->
	Str = int_untokens_help(Size - 1, Rest, Separator),
	integer_to_list(Int) ++ Separator ++ Str.

%% 将由许多整数和分割符组成的字符串解析为一个整数的列表，如"1|2|3"则被解析为[1,2,3]
%% 参数Seperator指定了分隔符
int_tokens(IntStr, Seperator) ->
	Index = string:chr(IntStr, Seperator),
	case Index > 0 of
		true ->
			Id = list_to_integer(string:substr(IntStr, 1, Index - 1)),
			lists:append(int_tokens(string:substr(IntStr, Index + 1), Seperator), [Id]);
		false ->
			[list_to_integer(string:substr(IntStr, 1))]
	end.

%% 将两个list中对应位置上的值进行相加并将结果组成一个list
%% 如：[1,2,3] + [2,2,2] = [3,4,5]
list_add([], []) -> [];
list_add(L1, L2) ->
	AddFun = fun(A1, A2) -> A1 + A2 end,
	two_list_map(L1, L2, AddFun, []).


%% 将L1中对应位置上元素减去L2对应位置上的元素，并将结果组成一个list
%% 如：[1,2,3] - [2,2,2] = [-1,0,1]
list_mis(L1, L2) ->
	MisFun = fun(A1, A2) -> A1 - A2 end,
	two_list_map(L1, L2, MisFun, []).

list_multiple(L1, L2) ->
	MulFun = fun(A1, A2) -> A1 * A2 end,
	two_list_map(L1, L2, MulFun, []).


%% 将2个list对应位置上的元素作为参数传递给函数MapFun，并将得到的结果组成一个list返回
two_list_map([], [], _MapFun, Result) -> Result;
two_list_map([E1 | L1], [E2 | L2], MapFun, Result) ->
	T = MapFun(E1, E2),
	two_list_map(L1, L2, MapFun, lists:append(Result, [T])).

%% 取两个整数中大的数
max(Num1, Num2) ->
	if
		Num1 > Num2 ->
			Num1;
		true ->
			Num2
	end.

%% 取两个整数中小的数
min(Num1, Num2) ->
	if
		Num1 > Num2 ->
			Num2;
		true ->
			Num1
	end.


%% 获取系统第二天开始时间秒数
get_sys_begin_time() ->
	SysBeginTime = {0,0,0}, %% data_system:get(38),
	%% {erlang:date(), Time}时区为本机时区
	BaseTime = calendar:datetime_to_gregorian_seconds({erlang:date(), SysBeginTime}),
	%% {calendar:local_time()}时区为本机时区
	NowTime = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
	Time1970 = calendar:datetime_to_gregorian_seconds({{1970, 1, 1}, {0, 0, 0}}),
	?INFO(localtime, "NowTime=~w", [NowTime - Time1970]),
	if
		NowTime > BaseTime ->
			BaseTime - Time1970 - get_diff_time();  %% 有8个小时的时差
		true ->
			BaseTime - Time1970 - ?SECONDS_PER_DAY - get_diff_time() %% 有8个小时的时差
	end.

test_time() ->
	BaseTime = calendar:datetime_to_gregorian_seconds({erlang:date(), erlang:time()}),
	NowTime = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
	Time1970 = calendar:datetime_to_gregorian_seconds({{1970, 1, 1}, {0, 0, 0}}),
	NowTime1 = unixtime(),
	?INFO(time, "BaseTime=[~w], NowTime1=[~w]", [BaseTime, NowTime1]),
	{(NowTime - Time1970- 8*3600) - NowTime1 , (BaseTime - Time1970 - 8*3600) - NowTime1}.

%% 检查传入时间是否比今天开始时间早，即检查当前时间与传入时间是否不在同一天
check_other_day(ComTime) ->
	NowTime = unixtime(),
	case get_diff_day(ComTime, NowTime) of
		{later, _} ->
			true;
		the_same_day ->
			false;
		_Other ->
			true
	end.

check_other_day(ComTime, NType) ->
	NowTime = unixtime(),
	case get_diff_day(ComTime, NowTime, NType) of
		{later, _} ->
			true;
		the_same_day ->
			false;
		_Other ->
			true
	end.

%% Time1 < Time2 返回:{later, 时间差}
%% Time1 > Time2 返回:{before, 时间差}
%% Time1 = Time2 返回:the_same_day
get_diff_day(Time1, Time2) ->
	{H, M, S} = {0, 0, 0},%% data_system:get(38),
	TmpTime1 = Time1 + get_diff_time()  - (H*3600 + M*60 + S),
	TmpTime2 = Time2 + get_diff_time()  - (H*3600 + M*60 + S),
	case (TmpTime2  div ?SECONDS_PER_DAY  - TmpTime1  div ?SECONDS_PER_DAY) of
		Time when Time > 0 ->
			{later, Time};
		Time when Time < 0 ->
			{before, -Time};
		_Time ->
			the_same_day  
	end.

%%根据Type宏定义在data文件取得对应的{H, M, S}，接着使用get_diff_day

get_diff_day(Time1, Time2, NType) ->
%% 	{H, M, S} = {22, 0, 0},
	%%竞技场的更新时间
	{H, M, S} = data_arena:get_system(NType),
	TmpTime1 = Time1 + get_diff_time()  - (H*3600 + M*60 + S),
	TmpTime2 = Time2 + get_diff_time()  - (H*3600 + M*60 + S),
	case (TmpTime2  div ?SECONDS_PER_DAY  - TmpTime1  div ?SECONDS_PER_DAY) of
		Time when Time > 0 ->
			{later, Time};
		Time when Time < 0 ->
			{before, -Time};
		_Time ->
			the_same_day  
	end.

%% 获取因为时区不一样引起的时间差
get_diff_time() ->
	%% unxitime()取的是从0年0月0日0时0分0秒距离现在的秒数（时区为0）
	NowTime = unixtime(),
	{Days, {H, M, S}} = calendar:seconds_to_daystime(NowTime),
	%% date(), time()取的是从1970年到现在的秒数（时区为本机所设置时区）
	Days1 = calendar:date_to_gregorian_days(date()),
	{H1, M1, S1} = time(),
	
	DiffTime = (Days1-Days-?DAYS_FROM_0_TO_1970)*?SECONDS_PER_DAY + (H1-H)*?SECONDS_PER_HOUR + (M1-M)*?SECONDS_PER_MINUTE + (S1-S),
	DiffTime.

%% 将字段列表用“,”分割。	
split(Str)->
	case length(Str) of 
		0->"";
		_N->"," 
	end.

%% 获取分页表示时的页码，输入（所取页数，所有记录数，每页显示数）
%% 输出：（ok，显示页序号，总页数，本页记录数）。	
get_page(Page,Num,Enum)->
	Ptt = Num div Enum,
	Prr = Num rem Enum,
	Pt = case Prr==0 of true->Ptt;false-> Ptt+1 end,
	Page1 = case Page>Pt of true->1;false->Page end,
	if (Prr==0)->{ok,Page1,Pt,Enum};
			(Pt==Page1)->{ok,Page1,Pt,Prr};
			(Pt>Page1)->{ok,Page1,Pt,Enum}
	end.

%% 获取分页显示的列表中本次需要显示的list。	
get_showlist(List,Page,Pnum)->
	case List of
		[]->{0,0,0,[]};
		ML->
			if(Page==0)->{0,0,length(ML),ML};
				true->			
					{ok,Pg,Pt,Num} = get_page(Page,length(ML),Pnum),
					ML1 = lists:sublist(ML, (Pg-1)*Pnum+1, Num),
					{Pt,Pg,Num,ML1}
			end
	end.
	
%%	将字符串用二进制表示。
string_to_binary(List)->
	N = list_to_binary(List),Ln=length(List),<<Ln:16,N/binary>>.
	
get_eff_list(Data)->
	{ok,Tokens1,_} = erl_scan:string(binary_to_list(Data)++"."),
	{ok,Y1} = erl_parse:parse_term(Tokens1),
	Y1.	


%% N 从1开始 Bin 要找的Bin
find_bit(N,Bin) ->
	if
		(size(Bin) *8) >= N ->
			N1 = N-1,
			<< _:N1,Bin1:1,_/bitstring >> = Bin,
			Bin1;
		true ->
			0
	end.

%% 替换 N从1开始
replace_bit(N,Value,Bin) ->
	if
		(size(Bin) *8) >= N ->
			N1 = N-1,
			<< Bin1:N1,_:1,Bin2/bitstring >> = Bin,			
			{ok,<< Bin1:N1,Value:1,Bin2/bitstring >>} ;
		true ->
			{ok,Bin}
	end.

%% 这个方法对传递进来的utctime没有考虑到时区的问题，因此被废弃了
%% %% 检查Time1和Time2是否是同一天，两个参数都是unixtime类型
%% %% 是同一天则返回0，Time1的天数大于Time2的天数返回1，Time1的天数小于Time2的天数返回2
%% is_same_day(Time1, Time2) ->
%% 	{Day1, _} = calendar:seconds_to_daystime(Time1),
%% 	{Day2, _} = calendar:seconds_to_daystime(Time2),
%% 	if
%% 		Day1 == Day2 -> 0;
%% 		Day1 >  Day2 -> 1;
%% 		true ->			2
%% 	end.

%%用来获取每日事件基准时间。
%%以小时数表示。
%%基准时间不一样则表示与上一次事件已经相差一天，可以重新执行
get_base_hours()->
	%%tax re-count will be reset on 3:00am every day.
	%%so set the day *24 + 3 as base line.
	{H,_,_} = time(),
	if
		%%3点之后，当天基准小时数为
		H > ?TIME_OFFSET -> 
			calendar:date_to_gregorian_days(date())*24+?TIME_OFFSET;
		true->
			(calendar:date_to_gregorian_days(date())-1)*24+?TIME_OFFSET
	end.

%%判断时间now在容差interval内是否整点
-spec oclock(pos_integer(), pos_integer())->true|false.
oclock(Now,Interval)->
	%%用现在秒数，对3600取余数，如果余数<?TIME_OUT * 0.5，或者余数>3600-?TIME_OUT * 0.5,
	R = Now rem 3600,
	(R < Interval * 0.5) orelse (R > 3600-Interval*0.5).

%% 检测点（X1, Y1）到点的（X2, Y2）距离是否小于等于Distance
check_distance(X1, Y1, X2, Y2, Distance) ->
	(erlang:abs(X1 - X2) =< Distance andalso erlang:abs(Y1 - Y2) =< Distance).

%% 获取点分十进制格式的ip字符串
get_format_ip(Socket) ->
	{ok, {{Ip1, Ip2, Ip3, Ip4}, _}} = inet:peername(Socket),
	Address1 = io_lib:format("~w.~w.~w.~w", [Ip1, Ip2, Ip3, Ip4]),
	Address1.

-spec get_daily_value(any(), any(), integer()) -> any().
get_daily_value(OrigValue, ResetTo, LastUpdateTime) ->
	Now = util:unixtime(),
	get_daily_value(OrigValue, ResetTo, LastUpdateTime, Now).

-spec get_daily_value(any(), any(), integer(), integer()) -> any().
get_daily_value(OrigValue, ResetTo, LastUpdateTime, Now) ->
	case util:get_diff_day(LastUpdateTime, Now) of
		the_same_day -> OrigValue;
		_ -> ResetTo
	end.

-spec check_command(binary1)->{ok,binary}|false.
check_command(Binary1)->
 	%%从进程字典获取上一次解码的时候的seq,如果不是比现在大1，则扔掉
	 <<Seq:16,Binary2/binary>> = Binary1,

	 Server_seq = case get(last_seq) of
	 undefined->
	 	%%cjr,为了便于测试,我们会从65500开始
	 	65501;
	 Num->
	 	if 
	 			%%Num == 65535->-1;
				Num == -1->65535;
	 			true->Num
	 		end 
	 end,
	
	 if
	 	%%Server_seq+1 /= Seq ->
		Server_seq-1 /= Seq ->
	 		Ret = false;
	 	true->
	 		put(last_seq,Seq),
	 		Ret = {ok,Binary2}
	 end,
	 Ret.
	% {ok, Binary1}.
reset_check_command() ->
	put(last_seq, 65499 + 2).

get_app_env(Env)->
	case application:get_env(server, Env) of
		{ok, Val} ->
			Val;
		_->
			Val = undefined
	end,
	Val.

get_log_app_env(Env) ->
	{ok, Val} = application:get_env(log, Env),
	Val.

%% 字符宽度，1汉字=2单位长度，1数字字母=1单位长度
string_width(String) ->
    string_width(String, 0).
string_width([], Len) ->
    Len;
string_width([H | T], Len) ->
    case H > 255 of
        true ->
            string_width(T, Len + 2);
        false ->
            string_width(T, Len + 1)
    end.

-spec get_rand_list_elems([any()], integer()) -> [any()].
get_rand_list_elems(OrigList, N) ->
    get_rand_list_elems(OrigList, N, []).

get_rand_list_elems(_, 0, AccList) ->
    AccList;
get_rand_list_elems(OrigList, N, AccList) ->
    FlatOList = lists:flatten(OrigList),
    Len = length(FlatOList),
    case Len =< N of
        true -> FlatOList;
        _ ->
            MidPos = util:rand(0, Len-1),
            {L, [M | R]} = lists:split(MidPos, FlatOList),
            get_rand_list_elems([L, R], N - 1, [M | AccList])
    end.

-spec randomize([any()]) -> [any()].
randomize(OrigList) ->
    Len = length(OrigList),
    [E || {_, E} <- lists:sort([{util:rand(1, Len), Elem} || Elem <- OrigList])].

schedule_timer(OldTimerRef, TimeOut, Msg) ->
    cancel_timer(OldTimerRef),
    NewTRef = erlang:send_after(TimeOut, self(), Msg),
    {NewTRef, Msg}.

cancel_timer(none) -> none;
cancel_timer({OldTimerRef, Msg}) ->
    erlang:cancel_timer(OldTimerRef),
    %% 清空消息队列里的Msg，免得timer被cancel前消息已经加到队列里
    receive
        Msg -> ok
        after 0 -> ok
    end,
    none.

get_daily_event_timeout(DailyStartTime) ->
    get_daily_event_timeout(DailyStartTime, calendar:local_time()).

get_daily_event_timeout(DailyStartTime, Now = {Date, Time}) ->
    NowSecs = calendar:datetime_to_gregorian_seconds(Now),
    TOSeconds = case Time >= DailyStartTime of
        true ->
            calendar:datetime_to_gregorian_seconds({Date, DailyStartTime}) + (24 * 60 * 60) - NowSecs;
        _ ->
            calendar:datetime_to_gregorian_seconds({Date, DailyStartTime}) - NowSecs
    end,
    case TOSeconds > 0 of
        true ->
            TOSeconds * 1000;
        _ ->
            0
    end.

deep_list_foldl(F, Acc, [E | Rest]) when is_list(E) ->
    NewAcc = deep_list_foldl(F, Acc, E),
    deep_list_foldl(F, NewAcc, Rest);
deep_list_foldl(F, Acc, [E | Rest]) when not is_list(E) ->
    NewAcc = F(E, Acc),
    deep_list_foldl(F, NewAcc, Rest);
deep_list_foldl(_, Acc, []) ->
    Acc.

check_and_set_cd(CDName, PlayerID, CDTime) ->
    Now = util:longunixtime(),
    LastTime = case erlang:get({CDName, PlayerID}) of
        undefined -> 0;
        T -> T
    end,
    case Now - LastTime >= CDTime of
        true ->
            erlang:put({CDName, PlayerID}, Now),
            true;
        _ ->        % false
            false
    end.

clear_cd(CDName, PlayerID) ->
    erlang:erase({CDName, PlayerID}).

get_list_index(List,Ele)->
	get_list_index_helper(List,Ele,0).

get_list_index_helper([],_Ele,_Index)-> 0;
get_list_index_helper([H|T],Ele,Index)->
	if 
		H == Ele -> Index+1;
		true-> get_list_index_helper(T,Ele,Index+1)
	end.
%只能是数字的相加
record_add(Rec1,Rec2) ->
	[H1|T1] = tuple_to_list(Rec1),
	[H2|T2] = tuple_to_list(Rec2),
	case H1 =:= H2 andalso length(T1) =:= length(T2) of
		true ->
			AccList = lists:zipwith(fun(X,Y) when is_integer(X), is_integer(Y)-> X+Y end, T1, T2),
			list_to_tuple([H1|AccList])
	end.

%只能是数字的叠加
record_merge(Rec1,Rec2) ->
	[H1|T1] = tuple_to_list(Rec1),
	[H2|T2] = tuple_to_list(Rec2),
	case H1 =:= H2 andalso length(T1) =:= length(T2) of
		true ->
			F = fun(X,Y) when is_integer(X), is_integer(Y)-> 
					case X == 0 orelse Y == 0 of
						true -> X + Y;
						false -> erlang:max(X, Y)
					end
				end,
			AccList = lists:zipwith(F, T1, T2),
			list_to_tuple([H1|AccList])
	end.

%记录的倍数
record_multiple(Rec,Num) ->
	[H|T] = tuple_to_list(Rec),
	F = fun(X) -> 
			case is_integer(X) of
                true ->
                    erlang:trunc(X * Num);
                false ->
                    X
            end
		end,
	AccList = lists:map(F, T),
	list_to_tuple([H|AccList]).

%计算一键修炼、研习等所加成的属性接口		
caculate_attri(MinId,MaxId,UpLevel,AccRec,F) ->
    F1 = fun(Level) ->
 			util:caculate_attri2(MinId,MaxId,Level,AccRec,F)
 	end,
    RecList = [F1(N) || N <- lists:seq(1, UpLevel)],
	lists:foldl(fun(Rec,AccRec1) -> util:record_merge(Rec, AccRec1) end, AccRec, RecList).

%caculate_attri是修炼到了最后一个id, caculate_attri2没有修炼到最后一个id
caculate_attri2(Id1,Id2,Level,AccRec,F) ->
	IdList1 = lists:seq(Id1, Id2),
	LevelList1 = lists:duplicate(length(IdList1), Level),
	TupleList1 = lists:zip(IdList1, LevelList1),
	List = lists:map(F, TupleList1),
	lists:foldl(fun(Rec,AccRec1) -> util:record_merge(Rec, AccRec1) end, AccRec, List).		

%一次修炼通用接口(人物Id,人物等级，所需升级等级，使用物品id,数量，元宝，铜币，消耗钱财类型)
one_time_cultivation(PlayerId,RoleLevel,NeedLevel,ItemId,Num,Gold,Silver,UseMoneyType) ->	
	case RoleLevel >=  NeedLevel of
		false ->%人物等级不足
			mod_err:send_err(PlayerId, ?ERR_NOT_ENOUGH_MER_LEVEL),
			skip;
		true ->	
			case ItemId /= 0 of
				true ->%需要使用物品，计算需要使用的铜币或元宝
					case mod_items:has_items(PlayerId, ItemId, Num) of
						true ->	
							check_and_use_silver_and_gold(PlayerId,ItemId,Num,Gold,Silver,UseMoneyType);							
						false ->
							mod_err:send_err(PlayerId, ?ERR_ITEM_NOT_ENOUGH),
							skip
					end;
				false ->%不需要使用物品
					check_and_use_silver_and_gold(PlayerId,ItemId,Num,Gold,Silver,UseMoneyType)
			end
	end.

check_and_use_silver_and_gold(PlayerId,ItemId,Num,Gold,Silver,UseMoneyType) ->
	case Silver /= 0 of
		true ->%需要花费铜币
			case mod_economy:check_silver(PlayerId, Silver) of 
				true ->
					case Gold /= 0 of
						true ->%需要花费元宝
							case mod_economy:check_gold(PlayerId, Silver, UseMoneyType) of 
								true ->
									mod_economy:use_silver(PlayerId, Silver, UseMoneyType),
									mod_economy:use_gold(PlayerId, Silver, UseMoneyType),										
									case ItemId /= 0 of
										true ->%直接使用物品，外层已经判断出有足够的物品
											mod_items:useNumByItemID(PlayerId, ItemId, Num),
											ok;
										false ->
											ok
									end;									
								false ->
									mod_err:send_err(PlayerId, ?ERR_NOT_ENOUGH_GOLD),
									skip
							end;
						false ->%不需要花费元宝，直接扣除铜币
							mod_economy:use_silver(PlayerId, Silver, UseMoneyType),								
							case ItemId /= 0 of
								true ->
									mod_items:useNumByItemID(PlayerId, ItemId, Num),
									ok;
								false ->
									ok
							end																																																
					end;																								
				false ->
					mod_err:send_err(PlayerId, ?ERR_NOT_ENOUGH_SILVER),
					skip
			end;
		false ->%不需要花费铜币
			case Gold /= 0 of
				true ->%直接使用元宝
					case mod_economy:check_and_use_gold(PlayerId, Gold, UseMoneyType) of 
						true ->
							case ItemId /= 0 of
								true ->
									mod_items:useNumByItemID(PlayerId, ItemId, Num),
									ok;
								false ->
									ok
							end;
						false ->
							mod_err:send_err(PlayerId, ?ERR_NOT_ENOUGH_GOLD),
							skip
					end;
				false ->%不需要花费元宝
					case ItemId /= 0 of
						true ->
							mod_items:useNumByItemID(PlayerId, ItemId, Num),
							ok;
						false ->
							ok
					end
			end											
	end.	

%% 根据规则获取下一轮修炼的等级
get_next_level(MaxId,Id,Level) ->
	case Id == MaxId of
		true ->
			Level + 1;
		false ->
			Level
	end.

%% 根据规则获取下一个要修炼的id
get_next_levelingId(MinId,MaxId,Id) ->
	case Id == MaxId of
		true ->
			MinId;
		false ->
			Id + 1
	end.
loop_judge(PlayerId,LevelingId,CurLevel,RoleLevel,OwnItemList,OwnSilver,CostItemList,OldSilverCost) ->
	case CurLevel >= data_zhenfa:get_max_level() of
        true ->
            mod_err:send_err(PlayerId, ?ERR_ZHENFA_LEVEL_FULL),
			[LevelingId,CurLevel,CostItemList,OldSilverCost];
        false ->
        	NeedLevel = data_zhenfa:get_needlevel_by_yanxi(CurLevel+1),
        	?INFO(zhenfa,"Needlevel:~w",[NeedLevel]),       			
			case RoleLevel >=  NeedLevel of
				false ->
					mod_err:send_err(PlayerId, ?ERR_NOT_ENOUGH_MER_LEVEL),
					[LevelingId,CurLevel,CostItemList,OldSilverCost];
				true ->			
					NewLevelingId = util:get_next_levelingId(?MIN_ZHENFA_ID,?MAX_ZHENFA_ID,LevelingId),
					{ItemId,Num} = data_zhenfa:get_need_items(NewLevelingId,CurLevel+1),
					case lists:keyfind(ItemId, 1, OwnItemList) of
						false ->
							mod_err:send_err(PlayerId, ?ERR_ITEM_NOT_ENOUGH),
							[LevelingId,CurLevel,CostItemList,OldSilverCost];
						Tuple ->
							{_,Num1} = Tuple,
							case Num1 >= Num of
								true ->	
									NewTuple = {ItemId,Num1 - Num},
									NewOwnList = lists:keyreplace(ItemId, 1, OwnItemList, NewTuple),
									NewCostItemList	= [{ItemId,Num}|CostItemList],							
									SilverCost = data_zhenfa:get_leveling_cost(CurLevel+1),
									NewSilverCost = OldSilverCost + SilverCost,
									case OwnSilver >= NewSilverCost of 
										true ->
											NewLevel = util:get_next_level(?MAX_ZHENFA_ID, NewLevelingId, CurLevel),
											loop_judge(PlayerId,NewLevelingId,NewLevel,RoleLevel,NewOwnList,OwnSilver,NewCostItemList,NewSilverCost);
										false ->
											mod_err:send_err(PlayerId, ?ERR_NOT_ENOUGH_SILVER),
											[LevelingId,CurLevel,CostItemList,OldSilverCost]
									end;
							false ->
									mod_err:send_err(PlayerId, ?ERR_ITEM_NOT_ENOUGH),
									[LevelingId,CurLevel,CostItemList,OldSilverCost]
							end
					end
			end
    end.
