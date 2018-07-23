-- luacheck: globals Websocket Keystore to_json from_json

local graphql = {}

local graphqlClients = "graphqlClients"
local graphqlAuthorization = "graphqlAuthorization"

function graphql.websocket(websocket_info)
    local socketId = websocket_info.socket_id
    if websocket_info.type == "open" then
        -- TODO: Remove this once users are filtered
        Keystore.command({
            key = graphqlClients,
            command = "sadd",
            args = {socketId}
        })
        return {message = "connected", type = "info"}
    elseif websocket_info.type == "close" then
        local authenticated = Keystore.command({
            key = graphqlClients,
            command = "sismember",
            args = {socketId}
            }).value
        if authenticated then
            local removed = Keystore.command({
                key = graphqlClients,
                command = "srem",
                args = {socketId}
            }).value
            print("ws disconnected, removing... " .. to_json(removed))
        end
        return
    end

    -- local message = websocket_info.message
    -- if message == nil then
    --     return
    -- end

    -- message = from_json(message)
    -- if message == nil then
    --     return {type = "error", message = "cannot parse message json"}
    -- end

    -- local type = tostring(message.type)
    -- if type == "authenticate" then
    --     if Keystore.get({key = graphqlAuthorization}).value == tostring(message.token) then
            -- Keystore.command({
            --     key = graphqlClients,
            --     command = "sadd",
            --     args = {socketId}
            -- })
            -- return {type = "authenticate", status = "success"}
    --     else
    --         print("No match on token value")
    --         return {type = "authenticate", status = "fail"}
    --     end
    -- else
    --     return {type = "error", status = "???"}
    -- end
end

-- TODO: Define events and valid event types
-- Current definition:
-- event.type: Type of event
-- event.event: Data for event
function graphql.send(event)
    -- Get a list of authenticated socket IDs
    local socket_ids = Keystore.command({
        key = graphqlClients,
        command = "smembers"
    }).value
    -- Send the event to each of those sockets
    if socket_ids and type(socket_ids) == "table" and #socket_ids > 0 then
        for _, socket_id in pairs(socket_ids) do
            if socket_id ~= nil then
                local resp = Websocket.send({
                    socket_id = socket_id,
                    message = to_json(event)
                })
                -- Sometimes sockets disconnect and they aren't cleaned up, if we send a WS message,
                -- and the socket isn't available, delete it
                if resp.error then
                    local err = resp.error or "{}"
                    local statusCode = (from_json(err) or {}).statusCode
                    if statusCode == 404 then
                        print("removing ws response: "..to_json(Keystore.command({
                        key = graphqlClients,
                        command = "srem",
                        args = {socket_id}
                    })))
                    end
                end
            end
        end
    end
end

return graphql

-- vim: set ai et sw=4 ts=4 :
