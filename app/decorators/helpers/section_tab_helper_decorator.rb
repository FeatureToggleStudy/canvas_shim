SectionTabHelper::AvailableSectionTabs.class_eval do
  def strongmind_to_a
    return instructure_to_a unless snapshot_enabled?

    if is_teacher_or_admin?
      instructure_to_a
    else
      tabs_without_snapshot
    end
  end

  alias_method :instructure_to_a, :to_a
  alias_method :to_a, :strongmind_to_a

  private
  def tabs_without_snapshot
    instructure_to_a.delete_if do |tab|
      tab_is?(tab, 'TAB_SNAPSHOT')
    end
  end

  def is_teacher_or_admin?
    return false unless @context.is_a?(Course) && @current_user
    @context.user_is_instructor?(@current_user) || @context.grants_right?(@current_user, session, :read_as_admin)
  end

  def snapshot_enabled?
    SettingsService.get_settings(object: :school, id: 1)['enable_course_snapshot']
  end
end
