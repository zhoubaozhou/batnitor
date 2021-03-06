-ifndef(__PLAYER_RECORD_HRL__).
-define(__PLAYER_RECORD_HRL__, 1).

-define(COMMON_PROPERTY_CROSS_FREND_INVITE, 1).

-define(COMMON_PROPERTY_CROSS_ALL_INVITE, 2).

% %% 玩家的相关数据记录
% -record(player, {
% 	gd_accountID      = 0,
% 	gd_guildId        = 0,		%% 公会id
% 	gd_Bag            = 0,		%% 背包大小
% 	gd_Bank           = 0,		%% 仓库大小
% 	gd_EmployableList = [],		%% 玩家的可招募列表
% 	gd_AccessMap	  = []		%% 玩家可以进入的地图列表
% 	}).

-record(player_types, {
	gd_accountID      = {integer},
	gd_guildId        = {integer},
	gd_Bag            = {integer},
	gd_Bank           = {integer},
	gd_EmployableList = {term},
	gd_AccessMap 	  = {term}
	}).

%%socket进程维护的信息,包含各模块调用所需pid
-record(player_status,{
			id                = 0,
			
			%% 与进程相关的
            cross_pid         = none,       %% 跨服pvp
			cave_pid		  = none, 		%% 藏宝洞
            rush_rank_pid     = none,       %% 冲榜活动
			soul_ball_pid     = none,       %% 魂珠系统
			notice_pid        = none,       %% 事件提醒
			rank_pid		  = none,		%% 排行榜     
            cool_down_pid     = none,
			player_sup_pid    = none,		%% cjr 玩家进程监控树
			player_pid        = none,		%% 玩家进程id
			reader_pid        = none,
			guild_pid         = none,
			scene_pid         = none,		%% 场景进程
			economy_pid		  = none,		%% 经济进程
			mer_pid           = none,     	%% 佣兵进程
			send_pid          = 0,	    	%% 玩家的广播进程ID列表
			move_queue_pid    = none, 		%% 移动包的发送队列进程
			socket            = none,	    %% 玩家socket
			chat_pid		  = none,
			items_pid         = none,   	%% 玩家物品系统进程
			task_pid          = none,		%% 玩家任务系统进程
			task_jungong_pid  = none,		%% 军功任务进程
			task_trace_pid	  = none,		%% 悬赏任务进程
			story_pid         = none,		%% 玩家的剧情进度进程
			battle_pid        = undefined,	%% 战斗进程
			relation_pid      = none, 		%% cjr 管理好友相关信息进程
			team_pid          = none,		%% cjr 管理组队相关信息进程
			horse_pid		  = none,		%% 坐骑进程
			fengdi_pid		  = none,		%% 封地进程
			official_pid 	  = none,    	%% 官职器魂模块	
			xunxian_pid		  = none,		%% 寻仙模块
			announcement_pid  = none,        %% 公告和系统广播进程
			achieve_pid       = none,		%% 成就模块
			target_pid		  = none,		%% 目标模块
			consume_pid		  = none,		%% 回馈模块
			vip_pid			  = none,		%% VIP模块
			dazuo_pid		  = none,		%% 打坐模块
			guide_pid		  = none,		%% 每日指引模块
			arena_pid         = none,		%% 竞技场模块
			guaji_pid		  = none,		%% 挂机模块
			sword_pid		  = none,		%% 神剑模块
			trade_pid		  = none,		%% 交易行模块
			answer_pid		  = none,		%% 问答活动模块
			junwei_role_pid   = none,		%% 军威将领模块
			yunbiao_pid       = none,        %% 运镖模块
			boss_pid          = none,         %%世界boss模块		  
			marstower_pid	  = none,        %% 英雄塔模块
            temp_bag_pid      = none,        %% 临时背包
            challenge_king_pid= none,		%% 挑战国王
			competition_pid   = none,		%% 比武模块
			wealth_pid 		  = none,		%% 招财进宝
			lottery_pid		  = none,		%% 投壶模块
			dressing_pid      = none,		%% 外形装扮（包括坐骑、换装、翅膀等）
			gift_pid		  = none, 		%% 礼物模块(各种首次大礼)
			stage_pid		  = none,		%% 挑战魂将(闯关)
			online_effect_pid = none,		%% 在线效果持续时间
			online_award_pid  = none,		%% 在线奖励
			title_pid         = none,		%% 称号模块
			territory_war_pid = none,		%% 领地战
			flower_pid        = none,		%% 送花模块
			exp_retrieve_pid  = none,       %% 经验找回
			stronger_pid      = none,		%% 我要变强
			kaifu_pid         = none,		%% 开服活动
			pk_pid            = none,		%% 切磋系统
			zhenfa_pid        = none,		%% 阵法系统
			hero_soul_pid     = none,		%% 将魂系统
			lucky_pid		  = none,  		%% 抽奖模块
			junliang_pid	  = none,  		%% 征收军粮
            guild_hunting_targets_pid = none,   %% 帮派活动目标
            formation_pid     = none,       %% 战斗阵型
            angry_pid 		  = none		%% 怒气储存模块
	}).

%%用户登录数据表
-record(account,{
	gd_accountID        = 0,
	gd_Account          ="", 
	gd_AccountRank      = 0, 
	gd_Sex              =0, 
	gd_AccountFCM       =0, 
	gd_RoleID           =0, 
	gd_RoleName         ="", 
	gd_Lock             =0, 
	gd_LockLimitTime    =0, 
	gd_ChatLock			=0,
	gd_chatLockTime		=0,
	gd_ActiveIP         ="", 
	gd_ActiveTime       =0, 
	gd_LastLoginTime    =0, 
	gd_LastLoginoutTime =0,
	gd_max_recv_global_mail_id = 0,
	gd_RegisterTime		= 0,
	
	gd_Password         =""
	
}).

-record(account_types,{
	gd_accountID 			= {integer},
	gd_Account	 			= {string}, 
	gd_AccountRank 			= {integer}, 
	gd_Sex 					= {integer}, 
	gd_AccountFCM 			= {integer}, 
	gd_RoleID 				= {integer}, 
	gd_RoleName				= {string}, 
	gd_Lock					= {integer}, 
	gd_LockLimitTime		= {integer}, 
	gd_ChatLock				= {integer},
	gd_chatLockTime			= {integer},
	gd_ActiveIP				= {string}, 
	gd_ActiveTime			= {integer},
	gd_LastLoginTime		= {integer}, 
	gd_LastLoginoutTime		= {integer},
	gd_max_recv_global_mail_id = {integer},
	gd_RegisterTime			= {integer},
	
	gd_Password				= {string}
}).

%% 与玩家相关的数据
-record (player_data, {
		gd_accountId       = 0,		
		gd_dayOnlineTime   = 0,			%% 当天在线时长(s)
		gd_totalOnlineTime = 0,			%% 总共在线时长(s)
		gd_fcmOnlineTime   = 0,			%% 防沉迷在线时间
		gd_fcmOfflineTime  = 0 			%% 防沉迷离线时间
	}).
-record (player_data_types, {
		gd_accountId       = {integer},		
		gd_dayOnlineTime   = {integer},	
		gd_totalOnlineTime = {integer},	
		gd_fcmOnlineTime   = {integer},	
		gd_fcmOfflineTime  = {integer} 	
	}).


-define(ETS_ONLINE,ets_online).

-define(STATE_PENDING,state_pending).
-define(STATE_RUNNING,state_running). 

-record(ets_online, {
		id,				%% player id
		accname   = "",		%% 帐号名
		nickname  = "",		%% 玩家昵称
		socket    = none,		%% 玩家socket
		
		%% 与进程相关的
		trade_pid = none,	%% 交易进程,add by wangyl 2011-10-24
		mer_pid   = none, 	%% 佣兵进程
		holy_pid  = none,	%% 圣痕进程 于2011-12-16被废弃
		send_pid  = 0,		%% 玩家的广播进程ID列表
		pid       = none,			%% 玩家进程id
		state = ?STATE_PENDING,
        is_shield_broadcast = 0   %% 0是不屏蔽广播， 1屏蔽
    }).

-define(VISITOR_ACCOUNT_EXISTS,5).
-define(VISITOR_ROLE_NAME_EXISTS,2).
-define(VISITOR_SUCCESS,0).

-endif.

