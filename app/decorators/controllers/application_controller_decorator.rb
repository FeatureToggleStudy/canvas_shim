ApplicationController.class_eval do
  prepend_view_path CanvasShim::Engine.root.join('app', 'views')

  def custom_placement_enabled?
    SettingsService.get_settings(object: :school, id: 1)['enable_custom_placement']
  end

  def strongmind_update_enrollment_last_activity_at
    return if logged_in_user != @current_user
    instructure_update_enrollment_last_activity_at
  end

  alias_method :instructure_update_enrollment_last_activity_at, :update_enrollment_last_activity_at
  alias_method :update_enrollment_last_activity_at, :strongmind_update_enrollment_last_activity_at

  def strongmind_content_tag_redirect(context, tag, error_redirect_symbol, tag_type=nil)
    if @maxed_out && tag.locked_for?(@current_user)
      maxout_message = <<~DESC
        You have not met the minimum requirements for your last activity.
        Please contact your teacher to proceed.
      DESC
      flash[:error] = t(maxout_message)
    end
    instructure_content_tag_redirect(context, tag, error_redirect_symbol, tag_type)
  end

  alias_method :instructure_content_tag_redirect, :content_tag_redirect
  alias_method :content_tag_redirect, :strongmind_content_tag_redirect
end
