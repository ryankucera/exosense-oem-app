--#ENDPOINT POST /api/claim
local u = require('users')
local user = u.verifyToken(request, response)
if user then
  local claimCode = tostring(request.body.claimCode)
  local userId = tostring(user.id)

  print("Claiming using code: "..claimCode)
  if not claimCode then
    return { error="no claim code supplied" }
  end

  local codeMatch = false
  local deviceMatch = false
  local d2resp = Device2.listIdentities()
  for i,device in pairs(d2resp.devices) do
    if device and device.state and device.state.claim_code then
      local claimResource = device.state.claim_code
      print("Claim resource: "..to_json(claimResource))
      local deviceCode = claimResource.set
      print("Device code: "..to_json(deviceCode))
      if deviceCode and deviceCode == claimCode then
        codeMatch = true
        deviceMatch = device
        break
      end
    end
  end

  print("Matching device: "..to_json(deviceMatch))
  if codeMatch and deviceMatch then
    local identity = deviceMatch.identity
    local key = tostring(identity)
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
  else
    print("response: "..to_json(response))
    return { error="Unable to find device that matches claim code" }
  end
end

--#ENDPOINT POST /api/devices/{identity}/unclaim
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

--#ENDPOINT GET /api/devices/{identity}
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

--#ENDPOINT GET /api/devices
local u = require('users')
local user = u.verifyToken(request, response)
if user then
  local userId = tostring(user.id)
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
      -- table.insert(devices, device)
    end
  end
  return setmetatable(devices, {['__type']='slice'})
end

