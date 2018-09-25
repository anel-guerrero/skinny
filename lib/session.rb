require 'json'
require 'byebug'

class Session
  attr_accessor :cookie
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    @cookie = req.cookies['_rails_lite_app']
    if @cookie
      @value = JSON.parse(@cookie)
    else
      @value = {}
    end
   
  end

  def [](key)
    @value[key]
  end
  
  def []=(key, val)
    # debugger
    @value[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    cookie = {path: '/', value: @value.to_json}
    res.set_cookie("_rails_lite_app", cookie)

  end
end