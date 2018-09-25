require 'byebug'
require_relative './controller_base'

class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern 
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name 
  end


  def matches?(req)
    !!(req.path =~ @pattern) && req.request_method == @http_method.to_s.upcase
  end

 
  def run(req, res)
    match_data = @pattern.match(req.path)
    params = {}
    if match_data.names
      match_data.names.each do |name|
        params[:name] = match_data.name
      end 
    end 
    
    controller = @controller_class.new(req, res, params)
    controller.invoke_action(@action_name)
    debugger
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end


  def draw(&proc)
    self.instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    @routes.each do |route|
      return route if route.matches?(req)
    end 
    nil
  end

  def run(req, res)
    route = self.match(req)
   if route
    route.run(req, res)
   else
    return ["No route was found"], res.status = 404
   end
  end
end
