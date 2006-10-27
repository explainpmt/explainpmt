class ReleaseObserver < ActiveRecord::Observer 
  
  # we have to reassign all the iterations
  def after_save(release) 
    iterations = Iteration.find(:all, :conditions => ['DATE_ADD(start_date, INTERVAL length DAY) >= ? and project_id = ?', Date.today, release.project_id])
    iterations.each do |i|
      i.release = nil
      i.save # trigger auto link to release
    end
  end 

end