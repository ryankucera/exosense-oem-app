local u = {}

function u.verifyToken(request, response)
  local authorization = request.headers.authorization
  if not authorization then
    response.status_code = 401
    return false
  end
  local user = User.getCurrentUser({
    token=authorization
  })
  if not user or user.error then
    response.message = 'invalid login'
    response.status_code = 401
    return false
  end
  return user
end

return u