#include <sourcemod>
#include <ripext>

#define AGONES_BASE_URL "http://127.0.0.1:9358"

public Plugin myinfo =
{
    name = "Agones Health",
    author = "OpenAI",
    description = "Agones SDK integration",
    version = "1.0"
};

Handle g_HealthTimer = INVALID_HANDLE;

public void OnPluginStart()
{
    PrintToServer("[AGONES] Plugin starting");

    CreateTimer(
        10.0,
        Timer_SetReady,
        _,
        TIMER_FLAG_NO_MAPCHANGE
    );

    g_HealthTimer = CreateTimer(
        2.0,
        Timer_SendHealth,
        _,
        TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE
    );
}

public Action Timer_SetReady(Handle timer)
{
    PrintToServer("[AGONES] Sending Ready()");

    HTTPRequest request = new HTTPRequest(
        AGONES_BASE_URL ... "/ready"
    );

    request.Post(
        null,
        HTTPCallback_Ready
    );

    return Plugin_Stop;
}

public Action Timer_SendHealth(Handle timer)
{
    HTTPRequest request = new HTTPRequest(
        AGONES_BASE_URL ... "/health"
    );

    request.Post(
        null,
        HTTPCallback_Health
    );

    return Plugin_Continue;
}

public void HTTPCallback_Ready(
    HTTPResponse response,
    any value
)
{
    if (response.Status != HTTPStatus_OK)
    {
        PrintToServer(
            "[AGONES] Ready failed: %d",
            response.Status
        );

        return;
    }

    PrintToServer("[AGONES] Ready successful");
}

public void HTTPCallback_Health(
    HTTPResponse response,
    any value
)
{
    if (response.Status != HTTPStatus_OK)
    {
        PrintToServer(
            "[AGONES] Health failed: %d",
            response.Status
        );

        return;
    }

    PrintToServer("[AGONES] Health OK");
}

public void OnPluginEnd()
{
    PrintToServer("[AGONES] Plugin unloading");
}
