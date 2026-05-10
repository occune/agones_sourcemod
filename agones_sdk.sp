#include <sourcemod>

#define AGONES_REST_URL "http://localhost:9358"

public Plugin my:plugin =
{
    public Function:OnPluginStart()
    {
        // 1. IDENTITY: Set unique Hostname from Pod Name
        char podName[64];
        if (GetEnv("POD_NAME", podName, sizeof(podName)) && podName[0] != '\0')
        {
            ConVar hName = FindConVar("hostname");
            if (hName != null)
            {
                hName.SetString(podName);
                PrintToServer("[Agones] Set hostname to: %s", podName);
            }
        }

        // 2. IDENTITY: Inject RCON Password from Environment
        char rconPass[64];
        if (GetEnv("RCON_PASS", rconPass, sizeof(rconPass)) && rconPass[0] != '\0')
        {
            // We use the engine command to set it in-memory
            char cmd[128];
            Format(cmd, sizeof(cmd), "rcon_password %s", rconPass);
            ServerCommand(cmd);
            PrintToServer("[Agones] RCON password injected from environment.");
        }

        // 3. LIFECYCLE: Tell Agones we are ready
        AgonesCall("ready");

        // 4. LIFECYCLE: Start Health Check timer
        CreateTimer(15.0, Timer_HealthCheck, _, TIMER_REPEAT);
    }

    public Action:Timer_HealthCheck(Handle timer)
    {
        AgonesCall("health");
        return Plugin_Continue;
    }

    public Action:OnMapEnd()
    {
        // 5. LIFECYCLE: Graceful Shutdown
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
