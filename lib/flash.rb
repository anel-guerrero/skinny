require 'json'

class Flash
  attr_accessor :now

  def initialize(req) 
    @cookie = req.cookies['_skinny_flash']
    if @cookie
      @now = JSON.parse(@cookie)
    else
      @now = {}
    end
    @flash = {}
  end

  def [](key) 
    @now[:key] || @flash[:key]
  end

  def []= (key, val)
    @now[:key] = val
  end

  def save_to_flash(res)
    cookie = {path: '/', value: @flash.to_json}
    res.set_cookie('_skinny_flash', cookie)
  end

end
