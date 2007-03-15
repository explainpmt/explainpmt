class StatsController < ApplicationController
def index 
  projectIterations = @project.iterations
  projectStories = @project.stories
  completedIterations = projectIterations.past
  numCompletedIterations = completedIterations.size
  @velocity = @project.current_velocity
  if projectIterations.size > 0  
  	@startdate = projectIterations.first.start_date
  end
  @pointsCompletedForProjectTotal = projectStories.points_completed
  @pointsNotCompletedForProjectTotal = projectStories.points_not_completed
  pointsCompletedPerIterationData = Array.new()
  pointsNotCompletedPerIterationData = Array.new()
  plannedCompletedPerIterationData = Array.new()
  totalPointsForProject = projectStories.total_points
  @plannedIterationsForProject = @project.planned_iterations
   
  #Determine completed points per iteration for graphing.  Need to also add these to not completed
  #data so that the graphs will overlap for work already done.  Also, calculate current iteration velocity
  pointsCompletedPerIterationData.push(totalPointsForProject)
  pointsNotCompletedPerIterationData.push(totalPointsForProject)
  plannedCompletedPerIterationData.push(totalPointsForProject)
  currentPointsForBurndown = totalPointsForProject
  completedIterations.each do |i| 
    currentPointsForBurndown = currentPointsForBurndown - i.stories.completed_points
    pointsCompletedPerIterationData = pointsCompletedPerIterationData.push(currentPointsForBurndown)
   	pointsNotCompletedPerIterationData =  pointsNotCompletedPerIterationData.push(currentPointsForBurndown)
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
	    pointsNotCompletedPerIterationData = pointsNotCompletedPerIterationData.push(remainingPointsForBurndown)
	end
  end

  #Determine how many iterations are remaining based on amount of work remaining
  @remainingiterations = pointsNotCompletedPerIterationData.length - pointsCompletedPerIterationData.length 
  
  #Determine slope for planned iterations.  First determine what the wanted velocity is for the project based
  #on the total work divided by the number of planned iterations for project.  Using the wanted velocity, begin
  #subtracting the wanted velocity from the total points until until points are 0.
  if (@plannedIterationsForProject != nil)
  @wantedVelocityForProject = ((@pointsCompletedForProjectTotal + @pointsNotCompletedForProjectTotal)/@plannedIterationsForProject)
  wantedpoints = totalPointsForProject
  @plannedIterationsForProject.times do
    wantedpoints = wantedpoints - @wantedVelocityForProject
    plannedCompletedPerIterationData.push(wantedpoints)
  end

  #Determine Iteration Gap from trended to planned
  @gapiterations = ((numCompletedIterations + @remainingiterations) - (plannedCompletedPerIterationData.length - 1))
  end
  
  #Begin building burndown chart using completed, trended, and planned data.
 
  g = Gruff::Line.new(550)
  g.theme ={
    :colors => %w('#72AE6E' '#FDD84E' red black),
   	:marker_color => 'black',
	:background_colors => ['#E6E6E6', '#E6E6E6']
  }
  g.title = "#{@project.name} Project Burndown"
  if (pointsCompletedPerIterationData.length > 1 || pointsNotCompletedPerIterationData.length > 1 || plannedCompletedPerIterationData.length > 1)
	g.labels = {
	1 => 'I1', 
	  pointsCompletedPerIterationData.length - 1 => 'I'+ (pointsCompletedPerIterationData.length - 1).to_s,
	  pointsNotCompletedPerIterationData.length - 1 => 'I'+ (pointsNotCompletedPerIterationData.length - 1).to_s,   
	  plannedCompletedPerIterationData.length - 1 => 'I'+ (plannedCompletedPerIterationData.length - 1).to_s,
	  }
	datasets = [[:Actual, pointsCompletedPerIterationData],[:Trend, pointsNotCompletedPerIterationData],[:Planned, plannedCompletedPerIterationData]]
  else
  	#This empty dataset is generated to display a graph with the Test NO DATA.  
  	datasets = [[:DUD, []]]
  end
  datasets.each do |data|
    g.data(data[0], data[1])
  end
  
  g.write("public/images/#{@project.name}burndown.png")
  end
end
