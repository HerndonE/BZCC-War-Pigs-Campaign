--------------------------------------------------------------------------
-- Warpigs Mission 2 Script (Cleaning House)
-- Author(s): JJ173 (AI_Unit), Gravey, Nielk1, Ded10c, F9Bomber, Ken
-- Date of last update: 28/05/2019
--------------------------------------------------------------------------

local _objective1 = "[Cleaning House]";
local _objective2 = "\n";
local _objective3 = "";

local DEBUG = true;

local Mission = {
	-- Ints
	TPS = 0,
	State = 0,
	MissionTimer = 0,
	TurnCounter = 0,
	DropshipClearCounter = 0,
	FirstScoutCounter = 0,

	-- Handles
	Player,
	Michael,
	Svetozar,
	Taylor,
	Transport,
	IScout1,
	FScout1,
	IScout2,
	FScout2,
	FTug,
	Teleporter,
	TalkingObject,

	-- Other
	talk = 0,

	-- Bools
	Scout1Finished = false,
	Scout2Finished = false,

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
	-- Run a fade command.
	SetColorFade(1, 1, Make_RGB(0, 0, 0));

	SetAutoGroupUnits(false);

	-- Get the player initially.
	Mission.Player = GetPlayerHandle(1);

	-- Grab Handles
	Mission.Michael = GetHandle("michael");
	Mission.Svetozar = GetHandle("svetozar");
	Mission.Taylor = GetHandle("taylor");
	Mission.Transport = GetHandle("transport");

	Mission.IScout1 = GetHandle("scout1");
	Mission.FScout1 = GetHandle("scout2");

	-- Get all ships to look at Jason at the start.
	LookAt(Mission.Michael, Mission.Player, 1);
	LookAt(Mission.Svetozar, Mission.Player, 1);
	LookAt(Mission.Taylor, Mission.Player, 1);
	LookAt(Mission.Transport, Mission.Player, 1);

	SetObjectiveOn(Mission.Transport);

	-- DEBUG
	if (DEBUG) then
		Stop(GetHandle("scav1"), 1);
	else
		Goto(GetHandle("scav1"), "scav_1_path", 1);
	end

	-- Set Base Plans for each team here.

	-- Set allied teams at the start to ensure no conflict.
	Ally(1, 2);
	Ally(2, 1);
	Ally(2, 3);
	Ally(3, 2);
	Ally(1, 3);
	Ally(3, 1);
end

function Update()
	-- Customised behaviour.
	if (IsAudioMessageDone(Mission.talk)) then
		if (IsAround(Mission.TalkingObject)) then
			SetObjectiveOff(Mission.TalkingObject);
			Mission.TalkingObject = nil;
			Mission.talk = 0;
		end
	end

	Mission.TurnCounter = Mission.TurnCounter + 1;
	MainCode();
end

function MainCode()
	Mission.Player = GetPlayerHandle(1);

	if (Mission.MissionTimer < Mission.TurnCounter) then
		if (Mission.State == 0) then
			PerformAudio(Mission.Taylor, "isdf0101.wav");
			Mission.State = Mission.State + 1;
		elseif (Mission.State == 1) then
			-- Possible Blah Here.

			if (IsAudioMessageDone(Mission.talk)) then
				Mission.State = Mission.State + 1;
			end
		elseif (Mission.State == 2) then
			-- More blah
			Mission.State = Mission.State + 1;
		elseif (Mission.State == 3) then
			-- More blah
			Mission.State = Mission.State + 1;
		elseif (Mission.State == 4) then
			Goto(Mission.Transport, "transport_path_1", 1);
			Stop(Mission.Taylor, 0);
			Stop(Mission.Svetozar, 0);
			Stop(Mission.Michael, 0);

			Mission.State = Mission.State + 1;
		elseif (Mission.State == 5) then
			if (GetDistance(Mission.Transport, "scout_trigger") <= 200) then
				Goto(Mission.IScout1, "scout_1_path", 1);
				Goto(Mission.FScout1, "scout_2_path", 1);

				if (GetDistance(Mission.IScout1, "scout_1_path") < 50 and not Mission.Scout1Finished) then
					Stop(Mission.IScout1, 1);
					LookAt(Mission.IScout1, "scout_lookat", 1);
					
					Mission.FirstScoutCounter = Mission.FirstScoutCounter + 1;

					Mission.Scout1Finished = true;
				end

				if (GetDistance(Mission.FScout1, "scout_2_path") < 50 and not Mission.Scout2Finished) then
					Stop(Mission.FScout1, 1);
					LookAt(Mission.FScout1, "scout_lookat", 1);

					Mission.FirstScoutCounter = Mission.FirstScoutCounter + 1;

					Mission.Scout2Finished = true;
				end

				if (Mission.FirstScoutCounter >= 2) then
					-- AudioMessage here.
					PerformAudio(Mission.Micahel, "isdf0102.wav");
					Mission.State = Mission.State + 1;
				end
			end
		elseif (Mission.State == 6) then
			if (GetDistance(Mission.Transport, "loop_point_trigger") < 40) then
				-- Perform Dialogue
				PerformAudio(Mission.Taylor, "isdf0103.wav");

				Mission.State = Mission.State + 1;
			end
		elseif (Mission.State == 7) then
			if (IsAudioMessageDone(Mission.talk)) then
				Mission.State = Mission.State + 1;
			end
		end
	end
end

function PerformAudio(handle, audio) 
	if (not IsAudioPlaying(Mission.talk)) then
		Mission.talk = AudioMessage(audio);
		Mission.TalkingObject = handle;
		SetObjectiveOn(Mission.TalkingObject);
	end
end