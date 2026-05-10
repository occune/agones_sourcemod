#include <sourcemod>
#include <ripext>

// Since we are using the older HTTPClient, we define a global client
HTTPClient g_httpClient;

public Plugin myinfo =
{
    name = "Agones Health Legacy",
    author = "Adaptive Collaborator",
    description = "Agones SDK integration using legacy HTTPClient",
    version = "1.0"
};

public void OnPluginStart()
{
    PrintToServer("[AGONES] Plugin starting using legacy HTTPClient");

    // Initialize the client pointing to the Agones Sidecar
    g_httpClient = new HTTPClient("http://127.0.0.1:9358");

    // Send Ready after 10 seconds
    CreateTimer(10.0, Timer_SetReady, _, TIMER_FLAG_NO_MAPCHANGE);

    // Send Health every 2 seconds
    CreateTimer(2.0, Timer_SendHealth, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_SetReady(Handle timer)
{
    PrintToServer("[AGONES] Sending Ready()");

    // In legacy RIPExt, Post takes (endpoint, data, callback)
    // We pass 'null' for data as /ready is a simple trigger
    g_httpClient.Post("ready", null, OnAgonesResponse);

    return Plugin_Stop;
}

public Action Timer_SendHealth(Handle timer)
{
    // PrintToServer("[AGONES] Sending Health()");
    g_httpClient.Post("health", null, OnAgonesResponse);

    return Plugin_Continue;
}

public void OnAgonesResponse(HTTPResponse response, any value)
{
    if (response.Status != HTTPStatus_OK)
    {
        PrintToServer("[AGONES] Request failed with status: %d", response.Status);
        return;
    }
}

public void OnPluginEnd()
{
    // Clean up the handle
    delete g_httpClient;
}
