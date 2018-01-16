module TournamentsHelper
  def date_helper(start_date, end_date)
    if start_date == end_date
      "#{start_date.strftime('%B')} #{start_date.day.ordinalize}"
    elsif start_date.month != end_date.month
      "#{start_date.strftime('%B %e')} - #{end_date.strftime('%B')} #{end_date.day.ordinalize}"
    else
      "#{start_date.strftime('%B %e')} - #{end_date.day.ordinalize}"
    end
  end
end
