module StoryPointCalc

  def points_completed
    completed.select("SUM(points) as amount").first.amount.to_i
  end

  def points_total
    select("SUM(points) as amount").first.amount.to_i
  end

  def points_remaining
    points_total.to_i - points_completed.to_i
  end

end