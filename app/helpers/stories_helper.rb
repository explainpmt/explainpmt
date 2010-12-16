module StoriesHelper
  
  def link_to_story_with_sc(story)
    link_to("SC#{story.scid}", project_story_path(@project, story)) + '(' + truncate(story.title, :length => 30) + ')'
  end
  
  def story_select_list_for(stories)
    stories.inject(""){|options, story| options << "<option value='#{story.id}'>SC#{story.scid}  (#{truncate(story.title, :length => 30)})</option>"}
  end
  
  def link_to_new_iteration_story(iteration)
    link_to 'Create Story Card', new_project_iteration_story_path(@project, iteration)
  end
end
