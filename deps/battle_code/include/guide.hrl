-define(GUIDE_TYPE_DUNGEON,		2).
-define(GUIDE_TYPE_TASK,		1).
-define(GUIDE_TYPE_ACTIVITY,	3).

-record(guide,{
			gd_AccountID = 0,
			gd_LastTime = 0,
			gd_InfoList = [],
			gd_FiltList = [],
			gd_BoxTaked = 0,
			gd_CheckIn  = 1,
			gd_Process  = 0,
			gd_ChargeProcess = 0
}).

-record(guide_types,{
			gd_AccountID = {integer},
			gd_LastTime = {integer},
			gd_InfoList = {term},
			gd_FiltList = {term},
			gd_BoxTaked = {integer},
			gd_CheckIn  = {integer},
			gd_Process  = {integer},
			gd_ChargeProcess = {integer}
	}).