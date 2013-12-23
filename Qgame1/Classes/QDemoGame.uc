class QDemoGame extends UTGame
config(game);


static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
	return Default.Class;
}
// this sets this game class as default - needed to compile correctly in "play on PC"


function PlayerStart ChoosePlayerStart( Controller Player, optional byte InTeam )
{

	local playerstart P;
	local int startiterator;
	local array<playerstart> startingpoints;

	startiterator = 0;

	foreach WorldInfo.AllNavigationPoints(class'PlayerStart', P)
	{
		startingpoints[startiterator] = P;
		startiterator = startiterator +1;
	}

	if (player != none)
	{
		`log("playerid: " $ player.PlayerReplicationInfo.PlayerID);
		if (player.PlayerReplicationInfo.PlayerID == 256)
			return startingpoints[1];
		if (player.PlayerReplicationInfo.PlayerID == 257)
			return startingpoints[0];
        if (player.PlayerReplicationInfo.PlayerID == 258)
			return startingpoints[2];

	}

	return startingpoints[1];

}

DefaultProperties
{

Acronym = "QU"
MapPrefixes[0] = "QU"

bGivePhysicsGun=false //don't need a gun
DefaultInventory(0)=none //don't need a gun
buseclassicHUD=true 
HUDType=class'QHud' 
//hudtype=none //get rid of the HUD


PlayerReplicationInfoClass=class'QPlayerReplicationInfo'
DefaultPawnClass=class'QPawn' //set custom pawn class 
PlayerControllerClass=class'QPlayerController'

bQuickStart = true



}
