#include <sourcemod>
#include <ripext/json>
#include <ripext/http>

public Plugin myinfo =
{
    name = "Agones Integration",
    author = "Your Name",
    description = "Ready, Health, and Shutdown calls for Agones using ripext",
    version = "1.1",
    url = "https://example.com"
};

public void OnPluginStart()
{
    char podName[64];
    GetCommandLineParam("pod_name", podName, sizeof(podName));
    if (podName[0] != '\0')
    {
        ConVar hName = FindConVar("hostname");
        if (hName != null) hName.SetString(podName);
    }

    char rconPass[64];
    GetCommandLineParam("rcon_pass", rconPass, sizeof(rconPass));
    if (rconPass[0] != '\0')
    {
        ServerCommand("rcon_password \"%s\"", rconPass);
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
    char url[128];
    Format(url, sizeof(url), "http://localhost:9358/%s", endpoint);

    HTTPRequest hRequest = new HTTPRequest(url);
    if (hRequest != null)
    {
        // Create an empty JSON object {}
        JSONObject json = new JSONObject();

        // Pass the JSON object to the Post request
        hRequest.Post(json, OnAgonesResponse);

        // Delete the handle to prevent memory leaks
        delete json;
    }
    else
    {
        PrintToServer("[Agones] Error: Failed to create HTTPRequest handle.");
    }
}

public void OnAgonesResponse(HTTPResponse response, any value)
{
    if (response.Status != HTTPStatus_OK)
    {
        PrintToServer("[Agones] SDK Call Failed with Status: %d", response.Status);
    }
}
