require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'byebug'
require 'active_support/inflector'
require_relative './flash'

class ControllerBase
  attr_reader :req, :res, :params
  attr_accessor :already_built_response

  # Setup the controller
  def initialize(req, res, route_params)
    @req = req
    @res = res
    @already_built_response = false
    @params = req.params.merge(route_params)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    self.already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    res.status = 302
    res['Location'] = url
    raise 'Already Built' if already_built_response?
    self.already_built_response = true
    session.store_session(@res)
    flash.save_to_flash(@res)
  end


  def render_content(content, content_type)
    raise 'Already Built' if already_built_response?
    self.already_built_response = true
    res['Content-Type'] = content_type
    res.write(content)
    session.store_session(@res)
    flash.save_to_flash(@res)
  end

  def render(template_name)
    # by
    path_start = File.dirname(__FILE__)
    path = File.join(
      path_start,
      '..', 'views',
      "#{self.class.name.underscore}",
      template_name.to_s+'.html.erb',
    )
    contents = File.read(path)

    result = ERB.new(contents).result(binding)
    render_content(result, 'text/html')
  
  end

  def session
    @session ||= Session.new(@req)
  end


  def invoke_action(name)
    self.send(name)
    render(name) unless already_built_response?
    nil
  end

  def flash
    @flash ||= Flash.new(@req)
  end
end