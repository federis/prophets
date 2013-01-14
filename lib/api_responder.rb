class ApiResponder < ActionController::Responder
  def to_format
    if get? || !has_errors? || response_overridden?
      if post?
        options.reverse_merge!({:template => "#{resource.class.model_name.pluralize.downcase}/show", 
                                :status => :created, 
                                :location => api_location})
      end
      
      default_render
    else
      display_errors
    end
  rescue ActionView::MissingTemplate => e
    api_behavior(e)
  end

  def json_resource_errors
    {:errors => resource.errors.full_messages}
  end
end