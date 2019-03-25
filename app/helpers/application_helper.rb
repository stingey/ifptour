module ApplicationHelper
  def full_title(title = '')
    base_title = 'Pro Foosball Tour'
    if title.empty?
      base_title
    else
      "#{title} | #{base_title}"
    end
  end

  def errors_for(object, field)
    object.displayed_errors ||= []
    output = "<div class='invalid-feedback' id='#{object.class.to_s.underscore}_#{field}_invalid_message'><ul>"
    object&.errors&.full_messages_for(field)&.each do |error|
      output += "<li>#{error.humanize}</li>"
      object.displayed_errors |= [field]
    end
    output += '</ul></div>'
    output.html_safe
  end
end
