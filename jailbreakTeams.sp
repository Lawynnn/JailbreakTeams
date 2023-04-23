#define PLUGIN_AUTHOR  "Lawyn"
#define PLUGIN_VERSION "*_*"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>

public Plugin myinfo =
{
	name		= "Jailbreak Teams",
	author		= PLUGIN_AUTHOR,
	description = "",
	version		= PLUGIN_VERSION,
	url			= ""
};

#define MIN_T_FOR_ONE_CT 3
int g_iLastJoined = -1;

public void OnPluginStart()
{
	AddCommandListener(listener_jointeam, "jointeam");
	HookEvent("player_spawn", event_playerspawn);
}

public int MY_GetTeamCount(int team)
{
	int c;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == team)
		{
			c++;
		}
	}
	return c;
}

bool IsJoinable(int div = 0)
{
	int ct = MY_GetTeamCount(CS_TEAM_CT) - div;
	int t  = MY_GetTeamCount(CS_TEAM_T) + div;
	int req_ct = t / MIN_T_FOR_ONE_CT;
	return t < 3 && ct <= 0 ? true : ct < req_ct;
}

public Action event_playerspawn(Event event, const char[] name, bool db)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client < 1 || client > MaxClients) return Plugin_Handled;

	if (GetClientTeam(client) == CS_TEAM_CT)
	{
		if (!IsJoinable(1))
		{
			if (g_iLastJoined > 0 && g_iLastJoined < MaxClients)
			{
				ChangeClientTeam(g_iLastJoined, CS_TEAM_T);
				PrintToChat(g_iLastJoined, " \x0e(System) \x01Ai fost mutat automat la prizonieri. \x0f(1CT/%iT)", MIN_T_FOR_ONE_CT);
				g_iLastJoined = -1;
			}
		}
	}

	return Plugin_Continue;
}

public Action listener_jointeam(int client, const char[] command, int argc)
{
	if (client < 1 || client > MaxClients) return Plugin_Handled;
    
    int prevTeam = GetClientTeam(client);
	char arg1[3];
	GetCmdArg(1, arg1, sizeof(arg1));
	int team = StringToInt(arg1);

	if (team == CS_TEAM_CT)
	{
		if (!IsJoinable())
		{
			PrintToChat(client, " \x0e(System) \x01Nu mai sunt locuri libere la gardieni. \x0f(1CT/%iT)", MIN_T_FOR_ONE_CT);
			return Plugin_Handled;
		}

		g_iLastJoined = client;
	}
	else if (team == CS_TEAM_T && g_iLastJoined == client) {
		g_iLastJoined = -1;
	}

	return Plugin_Continue;
}
