--#ENDPOINT POST /devices/claim
local u = require('users')
local user = u.verifyToken(request, response)
if user then
  local identity = tostring(request.parameters.identity)
  local claimCode = tostring(request.body.claimCode)
  local userId = tostring(user.id)

  print("Claiming device: "..identity.. " using code: "..claimCode)

  local key = identity
  local isClaimed = Keystore.get({ key=key })
  print("is claimed: "..to_json(isClaimed))
  if not isClaimed or not isClaimed.value then
    print("Claiming device: "..to_json(Keystore.command({
      key=key,
      command="hmset",
      args={ "claimedBy", userId, "claimed", true }})))
    print("Associating device with user: "..to_json(Keystore.command({
      key='user.'..tostring(userId),
      command="sadd",
      args={identity}
    })))
  else
    return { error="Device has been claimed" }
  end
end
--#ENDPOINT POST /devices/{identity}/unclaim
local u = require('users')
local user = u.verifyToken(request, response)
if user then
  local identity = tostring(request.parameters.identity)
  local userId = tostring(user.id)
  if not userId then
    return { error="Unauthorized", code=401}
  end

  print("Removing claim for device: "..identity)

  local key = identity
  local isClaimed = Keystore.command({ key=key, command="hgetall" })
  print("Is claimed: "..to_json(isClaimed).." user: "..to_json(user))
  if isClaimed and isClaimed.value and isClaimed.value.claimedBy == userId then
    print("Removing hash: "..to_json(Keystore.delete({ key=key })))
    print("Removing from user: "..to_json(Keystore.command({
      key='user.'..tostring(userId),
      command="srem",
      args={identity}
    })))
  else
    return { error="Device has been claimed" }
  end
end
--#ENDPOINT GET /devices/{identity}
local u = require('users')
local user = u.verifyToken(request, response)
if user then
  local identity = request.parameters.identity
  local device = Device2.getIdentity({ identity=identity })
  local hash = Keystore.command({ key=identity, command="hgetall" })
  device.meta = {}
  if hash and hash.value then
    for k,v in pairs(hash.value) do
      device.meta[k] = v
    end
  end
  return device
end
--#ENDPOINT GET /devices
local u = require('users')
local user = u.verifyToken(request, response)
if user then
  local userId = tostring(user.id)
  -- local userDevices = Keystore.command({ key='user.'..userId, command="smembers"})
  -- if userDevices then

  -- end
  local response = Device2.listIdentities()
  local devices = {}
  for i,device in pairs(response.devices) do
    local hash = Keystore.command({ key=device.identity, command="hgetall" })
    device.meta = {}
    if hash and hash.value then
      if hash.value.claimedBy == userId then
        -- device claimed by you
        for k,v in pairs(hash.value) do
            device.meta[k] = v
        end
        table.insert(devices, device)
      end
      -- This filters out devices that are claimed, but not by you
    else
      -- unclaimed devices
      table.insert(devices, device)
    end
  end

  return devices
end

