module StoryPointCalc

  def points_completed
    completed.points_total
  end

  def points_total
    sum(:points)
  end

  def points_remaining
    points_total.to_i - points_completed.to_i
  end
  
end