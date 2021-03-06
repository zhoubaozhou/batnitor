-ifndef(__COMMON_HRL__).
-define(__COMMON_HRL__, 1).

-include("chief_disciple.hrl").
-include("rank.hrl").

%% -include("zhentu.hrl").
-include("cross.hrl").
-include("soul_ball.hrl").
-include("cool_down.hrl").
-include("temp_bag.hrl").
-include("economy.hrl").
-include("constant.hrl").
-include("player_record.hrl").
-include("ets_sql_map.hrl").
-include("scene.hrl").
-include("role.hrl"). 
-include("spec_types.hrl"). 
-include("error_code.hrl"). 
-include("battle.hrl").
-include("guild.hrl").
-include("items.hrl").
-include("relation.hrl").
-include("fengdi.hrl").
-include("chuanqi.hrl").
 -include("gen_timer.hrl").
-include("arena.hrl").
-include("monster.hrl").
-include("uid_server.hrl"). 
-include("log_type.hrl"). 
-include("pet.hrl"). 
-include("counter.hrl"). 
-include("per_counter.hrl").
-include("sword.hrl").
-include("cave.hrl").
-include("answer.hrl").
-include("angry.hrl").

-include("rush_rank.hrl").


-include("team.hrl").
-include("code_log.hrl").

-include("dungeon.hrl"). 
-include("horse.hrl"). 
-include("official.hrl"). 
-include("xunxian.hrl").

-include("guaji.hrl").
-include("task.hrl").
-include("marstower.hrl").
-include("achieve.hrl").
-include("vip.hrl").

-include("run_business.hrl").

-include("announcement.hrl").

-include("gen_callback_server.hrl").

-include("mail_record.hrl").
-include("boss.hrl").
-include("fcm.hrl").
-include("system_enable.hrl").
-include("competition.hrl").
-include("target.hrl").
-include("guide.hrl").
-include("consume.hrl").

-include("challenge_king.hrl").
-include("dressing.hrl").
-include("defence.hrl").

-include("wealth.hrl").

-include("lottery.hrl").
-include("mines.hrl").
-include("multiple_award.hrl").
-include("stage.hrl").
-include("online_effect.hrl").
-include("title.hrl").
-include("guild_hunting.hrl").
-include("flower.hrl").
-include("week_counter.hrl").
-include("exp_retrieve.hrl").
-include("territory_war.hrl").
-include("stronger.hrl").
-include("zhenfa.hrl").
-include("hero_soul.hrl").
-include("market.hrl").
-include("fest.hrl").
-include("trade.hrl").
-include_lib("stdlib/include/ms_transform.hrl").

%%安全校验
-define(TICKET, "SDFSDESF123DFSDF").

%%flash843安全沙箱
-define(FL_POLICY_REQ, <<"<pol">>).
%-define(FL_POLICY_REQ, <<"<policy-file-request/>\0">>).
-define(FL_POLICY_FILE, 
		<<"<cross-domain-policy>"
		  		"<allow-access-from domain='*' to-ports='*' />"
		  "</cross-domain-policy>"
		>>).

%%tcp_server监听参数
-define(TCP_OPTIONS, [binary, {packet, 0}, {active, false}, 
					  {reuseaddr, true}, {nodelay, false}, 
					  {delay_send, true}, {send_timeout, 10000}, 
					  {keepalive, true}, {exit_on_close, true}]).

%%这张表用来维护server唯一的常量
%%用type做索引
%%如果用数字,取字段value_i
%%如果用字符串，取字段value_s
%%如果直接使用erlang的term，取字段value_t
%% type 类型
-define(G_SERVER_WEALTH_SILVER, 1). %% 招财进宝里的奖池总数 
-define(ADVANCE_ITEM_HISTORY_FROM_LOTTERY, 2). %% 投壶高级物品获得记录
-define(LOTTERY_HISTORY, 3). %% 投壶历史记录
-define(G_SERVER_WEALTH_CD, 4).%%招财进宝获取大奖的cd
-define(G_SERVER_MARKET_END_TIME, 5). %% 商城抢购结束时间
-define(G_SERVER_STAGE, 6). %% 挑战魂将(闯关)
-define(G_SERVER_DEFENCE_PLAYER_NUM, 7).    %% 上次参加群魔乱舞的人数
-define(G_SERVER_DEFENCE_HISTORY_KING_INFO, 8).    %% 群魔乱舞历届国王的信息，最多保存4个（在mod_defence里做）
-define(G_SERVER_FIRST_GUILD, 9).    %% 上次领地战胜利公会
-define(G_SERVER_WORLD_BOSS_OFFLINE, 10).    %% 世界boss离线卡使用情况
-define(G_SERVER_DUKANG_LUCKY, 11). %% 使用杜康酒抽奖历史记录
-define(G_SERVER_YINGXIONG_LUCKY, 12). %% 使用英雄酒抽奖历史记录
-define(G_SERVER_CROSS_WEEK_AWARD, 13). %% 周奖记录

-record (account_id_map, {account = "", id = 0}).
-record (rolename_account_map, {rolename = "", account = ""}).
-record (old_player_account_map, {gd_account = ""}).

-record(g_server_para,
	{
		type = 0,
		value_i = 0,
		value_t = undefined,
		value_s = ""
	}).

-record(g_server_para_types,
	{
		type = {integer},
		value_i = {integer},
		value_t = {term},
		value_s = {string}		
	}).

-define(G_SERVER_PARA_REF, cache_util:get_register_name(g_server_para)).


-endif.
