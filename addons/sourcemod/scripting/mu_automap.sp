#include <sourcemod>

#include <regex>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.0"

ConVar g_cvMap, g_cvEnabled, g_cvTime;
Regex g_rTime;
Timer g_Timer1, g_Timer2;

public Plugin myinfo =  {
	name = "Mix Utilities - Auto Map", 
	author = "ratawar", 
	description = "Goes to specified map if server goes empty (ignoring SourceTV).", 
	url = "https://forums.alliedmods.net/member.php?u=282996",
	version = PLUGIN_VERSION
}

public void OnPluginStart() {
	
	CreateConVar("sm_automap_version", PLUGIN_VERSION, "Plugin version.", FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD);
	
	g_cvMap = CreateConVar("sm_automap_map", "", "Map the server will go to when empty.");
	g_cvEnabled = CreateConVar("sm_automap_enable", "1", "Enable automap.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_cvTime = CreateConVar("sm_automap_time", "30", "Time in seconds before server changes map.", FCVAR_NOTIFY);
	
	g_rTime = CompileRegex("^[0-9]*$");
	
	AutoExecConfig(true, "AutoMap");
}

public void OnMapStart() {
	
	if (!g_cvEnabled.BoolValue)
		SetFailState("[AutoMap] Plugin disabled!");
	
	if (!IsAMMapValid())
		SetFailState("[AutoMap] Invalid map!");
	
	if (!IsValidTime())
		SetFailState("[AutoMap] Invalid time!");
	
	g_Timer1 = CreateTimer(30.0, CheckPlayers, _, TIMER_REPEAT);
}

void CheckPlayers(Handle g_Timer1) {

	if (GetClientCount(false) == 1)
		if (IsSourceTV()) {
		g_Timer2 = CreateTimer(30.0, ChangeMap);
	}

}

public void OnClientAuthorized() {
	g_Timer2.Close();
}

stock bool IsSourceTV() {
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i) && IsClientSourceTV(i))
		{
			return true;
		}
	}
	
	return false;
}

stock bool IsCurrMapEqualToSetMap() {
	char sMap[PLATFORM_MAX_PATH];
	g_cvMap.GetString(sMap, sizeof(sMap));
	char currentMap[PLATFORM_MAX_PATH];
	GetCurrentMap(currentMap, sizeof(currentMap));
	
	return (StrEqual(sMap, currentMap, false));
}

stock bool IsAMMapValid() {
	char sMap[PLATFORM_MAX_PATH];
	g_cvMap.GetString(sMap, sizeof(sMap));
	
	return (IsMapValid(sMap));
}

stock bool IsValidTime() {
	char time[PLATFORM_MAX_PATH];
	g_cvTime.GetString(time, sizeof(time));
	
	return (MatchRegex(g_rTime, time) == 0);
}

void ChangeMap(Handle timer) {
	char sMap[PLATFORM_MAX_PATH];
	g_cvMap.GetString(sMap, sizeof(sMap));
	KillTimer(timer);
	ForceChangeLevel(sMap, "Server empty, switching to set map...");
}