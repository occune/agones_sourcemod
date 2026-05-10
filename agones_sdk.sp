#include <sourcemod>

// 1. Metadata must be in the 'myinfo' struct and terminated with a semicolon
public Plugin myinfo =
{
    name = "Agones Integration",
    author = "Your Name",
    description = "Ready, Health, and Shutdown calls for Agones",
    version = "1.0",
    url = "https://example.com"
};

// 2. Functions must be in the global scope
public void OnPluginStart()
{
    char podName[64];
    // Note: GetCommandLineParam is not a standard SM native.
    // You might need an extension or use GetCommandLine().
    if (GetCommandLineParam("pod_name", podName, sizeof(podName)))
    {
        ConVar hName = FindConVar("hostname");
        if (hName != null)
        {
            hName.SetString(podName);
        }
    }

    char rconPass[64];
    if (GetCommandLineParam("rcon_pass", rconPass, sizeof(rconPass)))
    {
        ServerCommand("rcon_password %s", rconPass);
    }

    AgonesCall("ready");
    CreateTimer(15.0, Timer_HealthCheck, _, TIMER_REPEAT);
}

public Action Timer_HealthCheck(Handle timer)
{
    AgonesCall("health");
    return Plugin_Continue;
}

public void OnMapEnd()
{
    AgonesCall("shutdown");
}

void AgonesCall(const char[] endpoint)
{
    // WARNING: 'HTTPRequest' is not built-in.
    // You must include <SteamWorks> or another HTTP include here.
    /*
    char url[128];
    Format(url, sizeof(url), "http://localhost:9358/%s", endpoint);

    Handle hRequest = SteamWorks_CreateHTTPRequest(HTTPMethod_POST, url);
    if (hRequest != INVALID_HANDLE)
    {
        SteamWorks_SendHTTPRequest(hRequest);
    }
    */
}
