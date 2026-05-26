module ApplicationHelper
  def editable?
    local_assigns.fetch(:editable, true)
  end
end
