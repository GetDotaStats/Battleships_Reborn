--[[
Usage:

This is an example custom schema. You must assemble your game and players tables, which
are submitted to the library via a call like:

statCollection:sendCustom(schemaAuthKey, game, players)

The schemaAuthKey is important, and can only be obtained via site admins.

Come bug us in our IRC channel or get in contact via the site chatbox. http://getdotastats.com/#contact

]]
local customSchema = class({})
function customSchema:init(options)
    -- The schema version we are currently using
    self.SCHEMA_KEY = 'XXXXXXXXX' -- GET THIS FROM AN ADMIN ON THE SITE, THAT APPROVES YOUR SCHEMA
    -- Do we need to enable the round API or not.
    self.HAS_ROUNDS = true
    -- Do we want statCollection to use team winner for game victory?
    self.GAME_WINNER = true
    -- Do we want statCollection to use ancient explosions for game victory?
    self.ANCIENT_EXPLOSION = false
    --We want to have a reference to this later
    self.statCollection = options.statCollection
end

function customSchema:submitRound(args)
    winners = BuildRoundWinnerArray()
    game = BuildGameArray()
    players = BuildPlayersArray()

    self.statCollection:sendCustom({game=game, players=players})
    
    return {winners = winners, lastRound = false}
end

-------------------------------------
function BuildRoundWinnerArray()
    local winners = {}
	local emp_gold_south = getEmpGoldForTeam(DOTA_TEAM_GOODGUYS)
	local emp_gold_north = getEmpGoldForTeam(DOTA_TEAM_BADGUYS)
	local current_winner_team = DOTA_TEAM_GOODGUYS
	if emp_gold_south<emp_gold_north then
		DOTA_TEAM_BADGUYS
	end
	
    local current_winner_team = GetTeamWithMoreEmpGold()
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then
                winners[PlayerResource:GetSteamAccountID(playerID)] = (PlayerResource:GetTeam(playerID) == current_winner_team) and 1 or 0
            end
        end
    end
    return winners
end


function BuildGameArray()
    local game = {}
    game.emp_gold_south = getEmpGoldForTeam(DOTA_TEAM_GOODGUYS)
	game.emp_gold_north = getEmpGoldForTeam(DOTA_TEAM_BADGUYS)
	game.tide_killed = GetTideKill()
    return game
end

function BuildPlayersArray()
    players = {}
    for playerID = 0, DOTA_MAX_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            if not PlayerResource:IsBroadcaster(playerID) then
                table.insert(players, {
                    --steamID32 required in here
                    steamID32 = PlayerResource:GetSteamAccountID(playerID),
                    player_hero_name = GetHeroName(playerID),
                    player_kills = PlayerResource:GetKills(playerID),
                    player_deaths = PlayerResource:GetDeaths(playerID),
                    player_level = GetHeroLevel(playerID),
                    
					player_item_history_for_round=GetItemArray(playerID),
                })
            end
        end
    end

    return players
end

-------------------------------------

return customSchema