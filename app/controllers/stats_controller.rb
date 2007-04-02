class StatsController < ApplicationController
require 'scruffy'
require 'builder'
def index 
  projectIterations = @project.iterations
  projectStories = @project.stories
  @num_non_estimated_stories = Project.find_all_stories_not_estimated_and_not_cancelled(@project.id).size
  completedIterations = projectIterations.past
  numCompletedIterations = completedIterations.size
  @velocity = @project.current_velocity
  if projectIterations.size > 0  
  	@startdate = projectIterations.first.start_date
  end
  @pointsCompletedForProjectTotal = projectStories.points_completed
  @pointsNotCompletedForProjectTotal = projectStories.points_not_completed
  pointsCompletedPerIteration = Array.new()
  pointsNotCompletedPerIteration = Array.new()
  plannedCompletedPerIteration = Array.new()
  totalPointsForProject = projectStories.total_points
  @plannedIterationsForProject = @project.planned_iterations
   
  #Determine completed points per iteration for graphing.  Need to also add these to not completed
  #data so that the graphs will overlap for work already done.  Also, calculate current iteration velocity
  pointsCompletedPerIteration.push(totalPointsForProject)
  pointsNotCompletedPerIteration.push(totalPointsForProject)
  plannedCompletedPerIteration.push(totalPointsForProject)
  currentPointsForBurndown = totalPointsForProject
  completedIterations.each do |i| 
    currentPointsForBurndown = currentPointsForBurndown - i.stories.completed_points
    pointsCompletedPerIteration = pointsCompletedPerIteration.push(currentPointsForBurndown)
   	pointsNotCompletedPerIteration =  pointsNotCompletedPerIteration.push(currentPointsForBurndown)
  end


  #Determine burndown slope by taking the current uncompleted stories and associated story points and 
  #subtract the current velocity until the story points are 0

  remainingPointsForBurndown = @pointsNotCompletedForProjectTotal
  if (@velocity > 0)
    while remainingPointsForBurndown > 0
	  if remainingPointsForBurndown > @velocity
	    remainingPointsForBurndown = remainingPointsForBurndown - @velocity
	  else
	    remainingPointsForBurndown = 0
	  end
	    pointsNotCompletedPerIteration = pointsNotCompletedPerIteration.push(remainingPointsForBurndown)
	end
  end

  #Determine how many iterations are remaining based on amount of work remaining
  @remainingiterations = pointsNotCompletedPerIteration.length - pointsCompletedPerIteration.length 
  
  #Determine slope for planned iterations.  First determine what the wanted velocity is for the project based
  #on the total work divided by the number of planned iterations for project.  Using the wanted velocity, begin
  #subtracting the wanted velocity from the total points until until points are 0.
  if (@plannedIterationsForProject != nil)
  @wantedVelocityForProject = ((@pointsCompletedForProjectTotal + @pointsNotCompletedForProjectTotal)/@plannedIterationsForProject)
  wantedpoints = totalPointsForProject
  @plannedIterationsForProject.times do
    wantedpoints = wantedpoints - @wantedVelocityForProject
    plannedCompletedPerIteration.push(wantedpoints)
  end

  #Determine Iteration Gap from trended to planned
  @gapiterations = ((numCompletedIterations + @remainingiterations) - (plannedCompletedPerIteration.length - 1))
  end
  
  #Begin building burndown chart using completed, trended, and planned data.
    graph = Scruffy::Graph.new
    graph.title = "#{@project.name} Project Burndown"
    set_theme(graph)
    if (pointsCompletedPerIteration.length > 1 || pointsNotCompletedPerIteration.length > 1 || plannedCompletedPerIteration.length > 1)
      num_points = [plannedCompletedPerIteration.size, pointsNotCompletedPerIteration.size,
                pointsCompletedPerIteration.size].max
      
      create_line(graph, 'Planned', plannedCompletedPerIteration, num_points)
      create_line(graph, 'Trend', pointsNotCompletedPerIteration, num_points)
      create_line(graph, 'Actual', pointsCompletedPerIteration, num_points)
    
      graph.value_formatter = Scruffy::Formatters::Number.new()
      graph.point_markers = generate_point_markers(num_points, [plannedCompletedPerIteration.size, pointsNotCompletedPerIteration.size,
                pointsCompletedPerIteration.size])
    end
      graph.render(:width => 600, :min_value => 0, :to => "public/images/#{@project.name}burndown.svg")
  end
  
  def create_line(graph, title, points, numPoints)
    line = Scruffy::Layers::Line.new(:title => title, :points => points)
    line.set_number_of_points(numPoints)
    graph.add(line)
  end
  
  def generate_point_markers(total_number_of_labels, labels_to_add)
    Array.new(total_number_of_labels){|x| 'I' + x.to_s}
    labels = Array.new(total_number_of_labels, '')
    labels_to_add.each do |x| labels.insert(x - 1, 'I' + (x - 1).to_s); labels.delete_at(x) end
    labels
  end
  
  def set_theme(graph)
    graph.theme = Scruffy::Themes::Base.new(:colors => %w(#333399 #FDD84E #006600),
   	:marker => 'black',:background => '#E6E6E6')
  end
  
end
