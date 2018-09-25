require 'json'
require 'byebug'

class Session
  attr_accessor :cookie

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
    @value[key] = val
  end

  def store_session(res)
    cookie = {path: '/', value: @value.to_json}
    res.set_cookie("_rails_lite_app", cookie)

  end
end