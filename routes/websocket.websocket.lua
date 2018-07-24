--#ENDPOINT WEBSOCKET /api/subscribe
-- luacheck: globals websocketInfo request response
local graphql = require("graphql")
response.message = graphql.websocket(websocketInfo)