require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'byebug'
require 'active_support/inflector'

class ControllerBase
  attr_reader :req, :res, :params
  attr_accessor :already_built_response

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    self.already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    res.status = 302
    # res.location = url
    res['Location'] = url
    raise 'Already Built' if already_built_response?
    self.already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise 'Already Built' if already_built_response?
    self.already_built_response = true
    # res.content_type = content_type
    res['Content-Type'] = content_type
    res.write(content)


  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
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

  # method exposing a `Session` object
  def session
    
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end