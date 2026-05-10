#include <sourcemod>

#define AGONES_REST_URL "http://localhost:9358"

public Plugin my:plugin =
{
    public Function:OnPluginStart()
    {
        char podName[64];
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
            char cmd[128];
            Format(cmd, sizeof(cmd), "rcon_password %s", rconPass);
            ServerCommand(cmd);
        }

        AgonesCall("ready");
        CreateTimer(15.0, Timer_HealthCheck, _, TIMER_REPEAT);
    }

    public Action:Timer_HealthCheck(Handle timer)
    {
        AgonesCall("health");
        return Plugin_Continue;
    }

    public Action:OnMapEnd()
    {
        AgonesCall("shutdown");
        return Plugin_Continue;
    }
}

void AgonesCall(const char[] endpoint)
{
    char url[128];
    Format(url, sizeof(url), "%s/%s", AGONES_REST_URL, endpoint);

    HTTPRequest hRequest = CreateHTTPRequest(kHTTPRequest_GET);
    if (hRequest != null)
    {
        HTTPRequest_SetURL(hRequest, url);
        HTTPRequest_Send(hRequest);
    }
}

public void OnAgonesResponse(Handle hRequest, bool bSuccess, bool bError, const char[] error, int bytesRead, const char[] data, int dataLength)
{
    // Silent in production to prevent log flooding
}
