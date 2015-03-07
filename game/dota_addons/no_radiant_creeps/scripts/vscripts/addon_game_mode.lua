--[[
Variables
]]--
winTime = 15*60 -- seconds
xpGranterTime = 30 -- seconds
questReward = {200, 300, 400, 500} -- exp points 
questTime = {2*60+30, 3*60, 5*60, 6*60}

entQuest1 = nil
entQuest2 = nil
entQuest3 = nil
entQuest4 = nil

tower1 = nil
tower2 = nil
tower3 = nil
tower4 = nil

std1 = 0
std2 = 0
std3 = 0
std4 = 0

--entQuest = nil

--[[
Dota PvP game mode
]]
require('timers')

print( "Dota PvP game mode loaded." )

if DotaPvP == nil then
	DotaPvP = class({})
end

--------------------------------------------------------------------------------
-- ACTIVATE
--------------------------------------------------------------------------------
function Activate()
    GameRules.DotaPvP = DotaPvP()
    GameRules.DotaPvP:InitGameMode()
end

--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------

function DotaPvP:InitGameMode()
	local GameMode = GameRules:GetGameModeEntity()
				
		
	-- Enable the standard Dota PvP game rules
	GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled( true )

	-- Register Think
	GameMode:SetContextThink( "DotaPvP:GameThink", function() return self:GameThink() end, 0.25 )
  
	-- Register Game Events
	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap( DotaPvP, "OnGameRulesStateChange" ), self)
	ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap( DotaPvP, "OnDotaPlayerPickHero" ), self)
end

--------------------------------------------------------------------------------
function DotaPvP:GameThink()
	return 0.25
end


function DotaPvP:OnGameRulesStateChange()
	local CurrentState = GameRules:State_Get()
	print( "State Change: " .. CurrentState )
	
	if CurrentState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		print( "State Change: DOTA_GAMERULES_STATE_GAME_IN_PROGRESS" )
		DotaPvP:WinTimer()
		DotaPvP:CreateXpGranter()
		DotaPvP:DeleteRadiantSpawners()
		DotaPvP:QuestSystem()
	end
	
	if CurrentState == DOTA_GAMERULES_STATE_POST_GAME then
		print( "State Change: DOTA_GAMERULES_STATE_POST_GAME" )
		xp_granter:RemoveSelf()
	end
	
end


function DotaPvP:OnDotaPlayerPickHero( keys )
	print( "Player " .. keys.player .. " picks hero")
	
	
	local pickedHero = EntIndexToHScript( keys.heroindex )
	local curTeam = pickedHero:GetTeam()
	local curPlayer = pickedHero:GetOwner()
	
	if curTeam == DOTA_TEAM_GOODGUYS then
	ShowGenericPopupToPlayer( curPlayer, "#instructions_title", "#instructions_body_radiant", "", "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN )
	end
	if curTeam == DOTA_TEAM_BADGUYS then
	ShowGenericPopupToPlayer( curPlayer, "#instructions_title", "#instructions_body_dire", "", "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN )
	end
	
end



function DotaPvP:WinTimer()
	Timers:CreateTimer({
	  endTime = winTime,
	  callback = function()
	  local fort = Entities:FindByName(nil, "dota_badguys_fort")
	  fort:ForceKill(true)
	  GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
	  end
	})	
end

function DotaPvP:CreateXpGranter()
	Timers:CreateTimer({
	  endTime = xpGranterTime,
	  callback = function()
	  xp_granter = CreateUnitByName("npc_dota_xp_granter", Vector(0, 0, 0), true, nil, nil, DOTA_TEAM_BADGUYS)
	  end
	})
end


function DotaPvP:DeleteRadiantSpawners()
	local building1 = Entities:FindByName(nil, "lane_top_goodguys_melee_spawner")
	building1:RemoveSelf()

	local building2 = Entities:FindByName(nil, "lane_mid_goodguys_melee_spawner")
	building2:RemoveSelf()

	local building3 = Entities:FindByName(nil, "lane_bot_goodguys_melee_spawner")
	building3:RemoveSelf()
end


function DotaPvP:QuestSystem()
	local curName = "dota_goodguys_tower1_mid"
	local curText = "#quest_destroy_dota_goodguys_tower1_mid"
	
	tower1 = Entities:FindByName(nil, curName)
	std1 = tower1:GetDeathXP()
	tower1:SetDeathXP(questReward[1] + std1)
	entQuest1 = DotaPvP:AddTowerQuest(curText)
	DotaPvP:QuestTimer(entQuest1, questTime[1], tower1, std1)
	
	if RollPercentage(50) then
		curName = "dota_goodguys_tower1_top"
		curText = "#quest_destroy_dota_goodguys_tower1_top"
	else
		curName = "dota_goodguys_tower1_bot"
		curText = "#quest_destroy_dota_goodguys_tower1_bot"
	end
	
	tower2 = Entities:FindByName(nil, curName)
	std2 = tower2:GetDeathXP()
	tower2:SetDeathXP(questReward[2] + std2)
	entQuest2 = DotaPvP:AddTowerQuest(curText)
	DotaPvP:QuestTimer(entQuest2, questTime[2], tower2, std2)
	
	curName = "dota_goodguys_tower2_mid"
	curText = "#quest_destroy_dota_goodguys_tower2_mid"
	
	tower3 = Entities:FindByName(nil, curName)
	std3 = tower3:GetDeathXP()
	tower3:SetDeathXP(questReward[3] + std3)
	entQuest3 = DotaPvP:AddTowerQuest(curText)
	DotaPvP:QuestTimer(entQuest3, questTime[3], tower3, std3)
	
	if RollPercentage(50) then
		curName = "dota_goodguys_tower2_top"
		curText = "#quest_destroy_dota_goodguys_tower2_top"
	else
		curName = "dota_goodguys_tower2_bot"
		curText = "#quest_destroy_dota_goodguys_tower2_bot"
	end
	
	tower4 = Entities:FindByName(nil, curName)
	std4 = tower4:GetDeathXP()
	tower4:SetDeathXP(questReward[4] + std4)
	entQuest4 = DotaPvP:AddTowerQuest(curText)
	DotaPvP:QuestTimer(entQuest4, questTime[4], tower4, std4)
end

function DotaPvP:AddTowerQuest(text)

	local entQuest = SpawnEntityFromTableSynchronous( "quest", { name = "name" .. text, title = text } )
	return entQuest
end

function DotaPvP:QuestTimer(quest_entity, duration, ttt, xxx)
	Timers:CreateTimer({
		  endTime = duration,
		  callback = function()
			quest_entity:CompleteQuest()
			ttt:SetDeathXP(xxx)
		  end
		})

end
	
	--[[
	entQuestzzz = SpawnEntityFromTableSynchronous( "quest", { name = "DestroyTowerzzz", title = "AAA" .. "zzz" } )
	
	entQuest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_ROUND, 4 )
	entQuest:SetTextReplaceString( "Hello set" )
	
	entSubquestDestroyTower1 = SpawnEntityFromTableSynchronous( "subquest_base", {
		show_progress_bar = true,
		progress_bar_hue_shift = -79
	} )
	
	
	
	entSubquestDestroyTower2 = SpawnEntityFromTableSynchronous( "subquest_base", {
		show_progress_bar = true,
		progress_bar_hue_shift = 0
	} )
	
	entSubquestDestroyTower3 = SpawnEntityFromTableSynchronous( "subquest_base", {
		show_progress_bar = true,
		progress_bar_hue_shift = 22
	} )
	
	
	entQuest:AddSubquest(entSubquestDestroyTower1)
	entSubquestDestroyTower1:SetTextReplaceString("pls pls")
	
	entQuest:AddSubquest(entSubquestDestroyTower2)
	
	entQuestzzz:AddSubquest(entSubquestDestroyTower3)
	
	entSubquestDestroyTower1:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, 300)
	
	entSubquestDestroyTower1:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, 15 )
	
	entSubquestDestroyTower2:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, 14)
	
	entSubquestDestroyTower2:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, 10 )
	
	entSubquestDestroyTower3:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, 5)
	
	entSubquestDestroyTower3:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, 2 )
	
	
	Timers:CreateTimer({
	  endTime = 40,
	  callback = function()
		entSubquestDestroyTower1:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, 115 )
		
		entSubquestDestroyTower2:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, 2 )
		entSubquestDestroyTower3:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, 4 )
		
		entSubquestDestroyTower1:CompleteSubquest()
		entSubquestDestroyTower2:CompleteSubquest()
		
	  end
	})
	]]--


	--GameRules:SendCustomMessage("<font color='#66B2FF'>You should defend/destroy for 3 minute " .. strQuest .. ". Dire will get 300 exp points.</font>", 0, 0)
	
	--[[
	Timers:CreateTimer({
	  endTime = questTime,
	  callback = function()
		if tower1:IsAlive() then
			GameRules:SendCustomMessage("<font color='#FF6666'>" .. strQuest .. " is alive. Dire failed!</font>", 0, 0)
			tower1 = nil
		end
	  end
	})
	]]--