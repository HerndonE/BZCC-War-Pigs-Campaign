--------------------------------------------------------------------------
-- Warpigs Mission 8 Script (Relativity)
-- Author(s): JJ173 (AI_Unit), Gravey, Nielk1, Ded10c, F9Bomber, Ken
-- Date of last update: 28/05/2019
--------------------------------------------------------------------------

local _objective1 = "[RELATIVITY]";
local _objective2 = "\nEstablish a base, and scout the area.";
local _objective3 = "";

local Mission = {
	-- Ints
	TPS = 0,
	State = 0,
	MissionTimer = 0,
	TurnCounter = 0,
	DropshipClearCounter = 0,

	-- Handles
	Dropship1,
	Dropship2,
	Recycler,
	Healer1,
	Healer2,
	Player,

	-- Other
	talk = nil,

	-- Bools
	Dropship1Clear = false,
	Dropship2Clear = false,

	-- Tables

	-- Timers
	open_doors_sound_timer = 0,
	move_units_out_of_ship_timer = 0,
	dropship_remove_counter = 0,
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
	Mission.Recycler = GetHandle("Recycler");
	Mission.Dropship1 = GetHandle("dropship1");
	Mission.Dropship2 = GetHandle("dropship2");
	Mission.Healer1 = GetHandle("serv1");
	Mission.Healer2 = GetHandle("serv2");

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
			SetColorFade(1, 1, Make_RGB(0, 0, 0));

			-- Mask emitters on both dropships
			MaskEmitter(Mission.Dropship1, 0);
			MaskEmitter(Mission.Dropship2, 0);

			-- Open up the doors of the ship
			SetAnimation(Mission.Dropship1, "deploy", 1);
			SetAnimation(Mission.Dropship2, "deploy", 1);

			Mission.open_doors_sound_timer = Mission.open_doors_sound_timer + SecondsToTurns(2);

			Mission.State = Mission.State + 1;
		elseif (Mission.State == 1) then
			if (Mission.open_doors_sound_timer < Mission.TurnCounter) then
				StartSoundEffect("dropdoor.wav");

				Mission.move_units_out_of_ship_timer = Mission.move_units_out_of_ship_timer + SecondsToTurns(6);

				Mission.State = Mission.State + 1;
			end
		elseif (Mission.State == 2) then
			if (Mission.move_units_out_of_ship_timer < Mission.TurnCounter) then
				Goto(Mission.Recycler, "rally", 0);
				Goto(Mission.Healer1, "rally", 0);
				Goto(Mission.Healer2, "rally", 0);

				Mission.State = Mission.State + 1;
			end
		elseif (Mission.State == 3) then
			if (GetDistance(Mission.Recycler, Mission.Dropship1) > 75 and not Mission.Dropship1Clear) then
				DropshipTakeOff(Mission.Dropship1);
			end

			if (GetDistance(Mission.Healer1, Mission.Dropship2) > 75 and GetDistance(Mission.Healer2, Mission.Dropship2) > 75 and not Mission.Dropship2Clear) then
				DropshipTakeOff(Mission.Dropship2);
			end

			if (Mission.DropshipClearCounter >= 2) then
				Mission.dropship_remove_counter = Mission.dropship_remove_counter + SecondsToTurns(30);

				Mission.State = Mission.State + 1;
			end
		elseif (Mission.State == 4) then
			if (Mission.dropship_remove_counter < Mission.TurnCounter) then
				RemoveObject(Mission.Dropship1);
				RemoveObject(Mission.Dropship2);

				Mission.talk = AudioMessage("wp0801.wav");

				Mission.State = Mission.State + 1;
			end
		elseif (Mission.State == 5) then
			if (IsAudioMessageDone(Mission.talk)) then
				AddObjective(_objective1, "WHITE");
				AddObjective(_objective2, "WHITE");

				Mission.State = Mission.State + 1;
			end
		end
	end
end

function DropshipTakeOff(dropship)
	SetAnimation(dropship, "takeoff", 1);
	StartEmitter(dropship, 1);
	StartEmitter(dropship, 2);
	StartSoundEffect("dropleav.wav");

	if (dropship == Mission.Dropship1) then
		Mission.Dropship1Clear = true;
	end

	if (dropship == Mission.Dropship2) then
		Mission.Dropship2Clear = true;
	end

	Mission.DropshipClearCounter = Mission.DropshipClearCounter + 1;
end