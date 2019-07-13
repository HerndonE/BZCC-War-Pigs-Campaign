--------------------------------------------------------------------------
-- Warpigs Mission 2 Script (Cleaning House)
-- Author(s): JJ173 (AI_Unit), Gravey, Nielk1, Ded10c, F9Bomber, Ken
-- Date of last update: 28/05/2019
--------------------------------------------------------------------------

local _objective1 = "[Cleaning House]";
local _objective2 = "\n";
local _objective3 = "";

local Mission = {
	-- Ints
	TPS = 0,
	State = 0,
	MissionTimer = 0,
	TurnCounter = 0,
	DropshipClearCounter = 0,

	-- Handles
	Player,

	-- Other
	talk = nil,

	-- Bools

	-- Tables

	-- Timers
}

function Save()
	return Mission;
end

function Load(...)
    if select('#', ...) > 0 then
		Mission = ...;
    end
end

function AddObject(h)

end

function DeleteObject(h)

end

function InitialSetup()
	Mission.TPS = EnableHighTPS();
	AllowRandomTracks(true)

	local preloadODF = {
		"wvrecy",
		"wvtank",
		"wvhserv",
	}

	for k,v in pairs(preloadODF) do
		PreloadODF(v)
	end
end

function Start()
	SetAutoGroupUnits(false);

	-- Grab Handles
	AddScrap(1, 40);

	Ally(1,2);
	Ally(2,1);
end

function Update()
	Mission.TurnCounter = Mission.TurnCounter + 1;
	--MainCode();
end

function MainCode()
	Mission.Player = GetPlayerHandle(1);

	if (Mission.MissionTimer < Mission.TurnCounter) then
		if (Mission.State == 0) then
		
		end
	end
end