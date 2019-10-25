--------------------------------------------------------------------------
-- Warpigs Mission 1 Script (In the Shadows)
-- Author(s): JJ173 (AI_Unit), Gravey, Nielk1, Ded10c, F9Bomber, Ken
-- Date of last update: 25/10/2019
--------------------------------------------------------------------------

local _objective1 = "[In the Shadows]";
local _objective2 = "\n- Escort the Scientist Transport to the Missile Site";
local _objective3 = "\n - Defend the Scientist Transport";

local TaylorDied = "Taylor has deceased. Mission Failed.";
local SvetozarDied = "Svetozar has deceased. Mission Failed.";
local MicahelDied = "Micahel has deceased. Mission Failed.";

local DEBUG = true;

local Mission = {
	-- Ints
	TPS = 0,
	State = 0,
	MissionTimer = 0,
	TurnCounter = 0,
	DropshipClearCounter = 0,
	FirstScoutCounter = 0,
	Difficulty = 0,

	-- Handles
	Player,
	Michael,
	Svetozar,
	Taylor,
	Transport,
	IScout1,
	FScout1,
	IScout2,
	IScout3,
	FTug,
	Teleporter,
	TalkingObject,
	IRocket1,
	IRocket2,
	ScoutLookPoint,
	FWarrior1,
	FSentry1, 
	FSentry2,
	FWave1,
	FWave2, 
	FWave3,

	TempShip,

	-- Other
	talk = 0,

	-- Bools
	Scout1Finished = false,
	Scout2Finished = false,
	SendRockets = false,
	TaylorDead = false,
	MicahelDead = false,
	SvetozarDead = false,
	GameOver = false,

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
	-- Add handling for specific pilots.
	if (GetCfg(h) == "wspilo_sp") then
		if (not IsAround(Mission.Taylor)) then
			Mission.Taylor = h;
			SetObjectiveName(h, "Taylor Green");
			SetLabel(h, "taylor");
		elseif (not IsAround(Mission.Svetozar)) then
			Mission.Svetozar = h;
			SetObjectiveName(h, "Svetozar Andropov");
			SetLabel(h, "svetozar");
		elseif (not IsAround(Mission.Michael)) then
			Mission.Michael = h;
			SetObjectiveName(h, "Michael Grant");
			SetLabel(h, "michael");
		end

		SetGroup(h, 9);
	end
end

function DeleteObject(h)
	local label = GetLabel(h);

	-- Re-assign the variable to a ship that this pilot has got in.
	if (GetCfg(h) == "wspilo_sp") then
		if (h == Mission.Taylor) then
			if (label == GetLabel(Mission.TempShip)) then
				Mission.Taylor = Mission.TempShip;
				SetObjectiveName(Mission.TempShip, "Taylor Green");

				Mission.TempShip = nil;
			end
		elseif (h == Mission.Svetozar) then
			if (label == GetLabel(Mission.TempShip)) then
				Mission.Svetozar = Mission.TempShip;
				SetObjectiveName(Mission.Svetozar, "Svetozar Andropov");

				Mission.TempShip = nil;
			end
		elseif (h == Mission.Micahel) then
			if (label == GetLabel(Mission.TempShip)) then
				Mission.Micahel = Mission.TempShip;
				SetObjectiveName(Mission.Micahel, "Michael Grant");

				Mission.TempShip = nil;
			end
		end
	end
end

function ObjectKilled(deadObject)
	-- We need to ensure that we create a pilot that's controllable if certain ships die.
	if (deadObject == Mission.Taylor) then
		if (GetCfg(deadObject) == "wspilo_sp") then
			Mission.TaylorDead = true;

			ClearObjectives();
			AddObjective(TaylorDied, "RED");
		else
			EjectPilot(Mission.Taylor);
		end
	elseif (deadObject == Mission.Svetozar) then
		if (GetCfg(deadObject) == "wspilo_sp") then
			Mission.SvetozarDead = true;

			ClearObjectives();
			AddObjective(SvetozarDied, "RED");
		else
			EjectPilot(Mission.Svetozar);
		end
	elseif (deadObject == Mission.Michael) then
		if (GetCfg(deadObject) == "wspilo_sp") then
			Mission.MicahelDead = true;

			ClearObjectives();
			AddObjective(MicahelDied, "RED");
		else
			EjectPilot(Mission.Michael);
		end
	end
end

function PreGetIn(curWorld, pilotHandle, emptyCraftHandle) 
	-- Need handling here to ensure that the mission doesn't think that our special pilots die if they get in a craft.
	if (GetCfg(pilotHandle) == "wspilo_sp") then
		if (pilotHandle == Mission.Taylor) then
			Mission.TempShip = emptyCraftHandle;
			SetLabel(Mission.TempShip, "taylor");
		elseif (pilotHandle == Mission.Svetozar) then
			Mission.TempShip = emptyCraftHandle;
			SetLabel(Mission.TempShip, "svetozar");
		elseif (pilotHandle == Mission.Michael) then
			Mission.TempShip = emptyCraftHandle;
			SetLabel(Mission.TempShip, "michael");
		end
	end

	return 1;
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

	-- Set the mission difficulty based on the players options.
	Mission.Difficulty = GetVarItemInt("options.play.difficulty");

	-- Get the player initially.
	Mission.Player = GetPlayerHandle(1);

	-- Grab Handles
	Mission.Michael = GetHandle("michael");
	Mission.Svetozar = GetHandle("svetozar");
	Mission.Taylor = GetHandle("taylor");
	Mission.Transport = GetHandle("transport");

	Mission.IScout1 = GetHandle("scout1");
	Mission.FScout1 = GetHandle("scout2");

	Mission.IRocket1 = GetHandle("rocket1");
	Mission.IRocket2 = GetHandle("rocket2");

	Mission.ScoutLookPoint = GetHandle("scout_look_point");
	Mission.Teleporter = GetHandle("unnamed_ibtele");

	Mission.FWarrior1 = GetHandle("warrior1");
	Mission.FSentry1 = GetHandle("sentry1");
	Mission.FSentry2 = GetHandle("sentry2");

	Mission.IScout2 = GetHandle("IScout2")
	Mission.IScout3 = GetHandle("IScout3");

	-- Set specific pilots on for our main characters.
	SetPilotClass(Mission.Michael, "wspilo_sp");
	SetPilotClass(Mission.Svetozar, "wspilo_sp");
	SetPilotClass(Mission.Taylor, "wspilo_sp");

	-- Ensure our characters always eject
	SetEjectRatio(Mission.Michael, 1)
	SetEjectRatio(Mission.Svetozar, 1)
	SetEjectRatio(Mission.Taylor, 1)

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

	if (DEBUG) then
		--print(Mission.State);
		--Mission.State = 10;
	end

	-- Mission Conditions.
	if (not Mission.GameOver) then
		if (Mission.TaylorDead) then
			FailMission(10, "");
			Mission.GameOver = true;
		elseif (Mission.SvetozarDead) then
			FailMission(10, "");
			Mission.GameOver = true;
		elseif (Mission.MicahelDead) then
			FailMission(10, "");
			Mission.GameOver = true;
		elseif (not IsAlive(Mission.Transport)) then
			FailMission(10, "");
			Mission.GameOver = true;
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
			AddObjective(_objective1, "WHITE");
			AddObjective(_objective2, "WHITE");

			Goto(Mission.Transport, "transport_path_1", 1);
			Stop(Mission.Taylor, 0);
			Stop(Mission.Svetozar, 0);
			Stop(Mission.Michael, 0);

			Mission.State = Mission.State + 1;
		elseif (Mission.State == 5) then
			if (GetDistance(Mission.Transport, "scout_trigger") <= 75.0) then
				Goto(Mission.IScout1, "scout_1_path", 1);
				Goto(Mission.FScout1, "scout_2_path", 1);

				Mission.State = Mission.State + 1;
			end
		elseif (Mission.State == 6) then
			if (GetDistance(Mission.IScout1, "scout_1_path") <= 25.0 and not Mission.Scout1Finished) then
				Stop(Mission.IScout1, 1);
				LookAt(Mission.IScout1, Mission.ScoutLookPoint, 1);
				
				Mission.FirstScoutCounter = Mission.FirstScoutCounter + 1;

				Mission.Scout1Finished = true;
			end

			if (GetDistance(Mission.FScout1, "scout_2_path") <= 25.0 and not Mission.Scout2Finished) then
				Stop(Mission.FScout1, 1);
				LookAt(Mission.FScout1, Mission.ScoutLookPoint, 1);

				Mission.FirstScoutCounter = Mission.FirstScoutCounter + 1;

				Mission.Scout2Finished = true;
			end

			if (Mission.FirstScoutCounter >= 2) then
				-- AudioMessage here.
				PerformAudio(Mission.Michael, "isdf0102.wav");
				Mission.State = Mission.State + 1;
			end
		elseif (Mission.State == 7) then
			if (GetDistance(Mission.Transport, "loop_point_trigger") <= 250 and not Mission.SendRockets) then
				Goto(Mission.IRocket1, "rocket_path", 1);
				Goto(Mission.IRocket2, "rocket_path", 1);

				Mission.SendRockets = true;
			end

			if (GetDistance(Mission.Transport, "loop_point_trigger") <= 40) then
				-- Perform Dialogue
				PerformAudio(Mission.Taylor, "isdf0103.wav");

				Mission.State = Mission.State + 1;
			end
		elseif (Mission.State == 8) then
			if (IsAudioMessageDone(Mission.talk)) then
				Mission.State = Mission.State + 1;
			end
		elseif (Mission.State == 9) then
			Goto(Mission.Transport, "transport_path_2", 1);
			Mission.State = Mission.State + 1;
		elseif (Mission.State == 10) then
			-- Time for a cutscene.
			if (GetDistance(Mission.Transport, Mission.Teleporter) < 75) then
				-- TODO: Add Cutscene when we have rocket model.
				PerformAudio(Mission.Svetozar, "isdf0104.wav");
				Mission.State = Mission.State + 1;
			end
		elseif (Mission.State == 11) then
			PerformAudio(Mission.Michael, "isdf0105.wav");
			UnAlly(2, 3);
			UnAlly(3, 2);
			UnAlly(1, 2);
			UnAlly(2, 1);

			SetTeamNum(Mission.Teleporter, 0);

			ClearObjectives();
			AddObjective(_objective1, "WHITE");
			AddObjective(_objective3, "WHITE");

			Attack(Mission.FWarrior1, Mission.Player, 1);
			Attack(Mission.FSentry1, Mission.Transport, 1);
			Attack(Mission.FSentry2, Mission.Transport, 1);

			Attack(Mission.IScout2, Mission.FWarrior1, 1);
			Attack(Mission.IScout3, Mission.FSentry2, 1);

			Mission.State = Mission.State + 1;
		elseif (Mission.State == 12) then
			-- Do some checks before advancing the mission state.
			if (not IsAlive(Mission.FWarrior1) and not IsAlive(Mission.FSentry1) and not IsAlive(FSentry2)) then
				if (IsAlive(Mission.IScout2)) then
					SetTeamNum(Mission.IScout2, 1);
					Stop(Mission.IScout2, 1);
					SetGroup(Mission.IScout2, 6);
				end

				if (IsAlive(Mission.IScout3)) then
					SetTeamNum(Mission.IScout3, 1);
					Stop(Mission.IScout3, 1);
					SetGroup(Mission.IScout2, 7);
				end

				PerformAudio(Mission.Svetozar, "isdf0106.wav");

				Mission.State = Mission.State + 1;
			end
		elseif (Mission.State == 13) then
			if (IsAudioMessageDone(Mission.talk)) then
				-- Spawn enemies here.
				Goto(BuildObject("fvscout", 2, "spawn_wave"), "cut_off_1", 1);
				Goto(BuildObject("fvscout", 2, "spawn_wave"), "cut_off_2", 1);
				Goto(BuildObject("fvscout", 2, "spawn_wave"), "cut_off_3", 1);

				Mission.FWave1 = BuildObject("fvscout", 2, "spawn_wave");
				Mission.FWave2 = BuildObject("fvsent", 2, "spawn_wave");
				Mission.FWave3 = BuildObject("fvsent", 2, "spawn_wave")

				Attack(Mission.FWave1, Mission.Player, 1);
				Attack(Mission.FWave2, Mission.Transport, 1);
				Attack(Mission.FWave3, Mission.Transport, 1);

				Mission.State = Mission.State + 1; 
			end
		elseif (Mission.State == 14) then
			-- Once enemies are dead, move the transport back to base between waves. Send healer reinforcements to the player.
			if (not IsAlive(Mission.FWave1) and not IsAlive(Mission.FWave2) and not IsAlive(Mission.FWave3)) then
				PerformAudio(Mission.Taylor, "isdf0107.wav");

				Goto(Mission.Transport, "transport_path_3", 1);

				Mission.State = Mission.State + 1;
			end
		elseif (Mission.State == 15) then
			if (GetDistance(Mission.Transport, "cut_off_announcement") < 50) then
				Stop(Mission.Transport, 0);
				PerformAudio(Mission.Taylor, "isdf0108.wav");

				Mission.State = Mission.State + 1;
			end
		end
	end
end

function PerformAudio(handle, audio) 
	-- If we call this method while audio is playing, we should cut it off and start again.
	if (IsAudioPlaying(Mission.talk)) then
		StopAudioMessage(Misison.talk);
		
		if (IsAround(Mission.TalkingObject)) then
			Mission.TalkingObject = nil;
		end
	end

	if (not IsAudioPlaying(Mission.talk)) then
		Mission.talk = AudioMessage(audio);
		Mission.TalkingObject = handle;
		SetObjectiveOn(Mission.TalkingObject);
	end
end