
--#ENDPOINT POST /api/users/login
local email = request.body.email
local password = request.body.password
if not email or not password then
  return { error="Invalid parameters", status_code=403 }
end
local response = User.getUserToken({
  email=email,
  password=password,
  time_to_live=24*60*60
})
if response.error ~= nil then
  return { error="Invalid login", status_code=400 }
end
local token = response
return response

--#ENDPOINT POST /api/users/create
local name = request.body.name
local email = request.body.email
local password = request.body.password

if not name or not password or not email then
  return { error="Invalid parameters", status_code=403 }
end
local response = User.createUser({
  name=name,
  password=password,
  email=email
})
if response and response.error == nil then
  local activate = User.activateUser({
    code=response
  })
  return User.getUserToken({
    email=email,
    password=password,
    time_to_live=24*60*60
  })
end
return { error="Couldnt create user - does user already exist?" }

--#ENDPOINT GET /api/users
local u = require('users')
local user = u.verifyToken(request, response)
if user then
  return User.listUsers()
end

--#ENDPOINT GET /api/users/currentUser
local u = require('users')
local user = u.verifyToken(request, response)
if user then
  return user
end


--#ENDPOINT POST /api/users/delete
local u = require('users')
local user = u.verifyToken(request, response)
if user then
  local id = request.body.id
  return User.deleteUser({ id=id })
end
