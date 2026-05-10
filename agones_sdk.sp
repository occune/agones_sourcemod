#include <sourcemod>
#include <ripext/http>

// 1. Plugin Metadata
public Plugin myinfo =
{
    name = "Agones Integration",
    author = "Your Name",
    description = "Ready, Health, and Shutdown calls for Agones using ripext",
    version = "1.1",
    url = "https://example.com"
};

// 2. Lifecycle Callbacks
public void OnPluginStart()
{
    char podName[64];
    // Using GetCommandLineParam to read the identity passed from K8s
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

public void OnMapEnd()
{
    AgonesCall("shutdown");
}

// 3. The Functional AgonesCall using ripext
void AgonesCall(const char[] endpoint)
{
    char url[128];
    // The Agones sidecar listens on the HTTP port specified in AGONES_SDK_HTTP_PORT
    Format(url, sizeof(url), "http://localhost:9358/%s", endpoint);

    HTTPRequest hRequest = HTTPRequest(url);
    if (hRequest != null)
    {
        // We use the Get method for simple lifecycle signals
        hRequest.Get(OnAgonesResponse, 0);
    }
    else
    {
        PrintToServer("[Agones] Error: Failed to create HTTPRequest handle.");
    }
}

// 4. The HTTP Callback
public void OnAgonesResponse(HTTPResponse response, any value)
{
    if (response.Status == HTTPStatus_OK)
    {
        // Success!
    }
    else if (response.Status != HTTPStatus_Invalid)
    {
        PrintToServer("[Agones] SDK Call Failed with Status: %d", response.Status);
    }
}

// Required for the callback signature in ripext
public void OnAgonesResponseError(HTTPResponse response, any value, const char[] error)
{
    PrintToServer("[Agones] SDK Call Error: %s", error);
}
