module ApplicationHelper
  include AcceptancetestsHelper
  include DashboardsHelper
  include InitiativesHelper
  include IterationsHelper
  include MilestonesHelper
  include ProjectsHelper
  include ReleasesHelper
  include StoriesHelper
  include TasksHelper
  include UsersHelper

  VERSION = 'dev trunk'

  def admin_content(&block)
    yield if is_admin?
  end

  def collection_content(collection, &block)
    yield collection if collection and collection.size > 0
  end

  def empty_collection_content(collection, &block)
    yield if collection.size == 0
  end

  def column_content_for(cols, column, &block)
    yield unless cols.include?(column)
  end

  def error_container(error)
    "<div id='SystemError'>#{error}</div>"
  end

  def render_pagination(collection, options={})
    render :partial => 'shared/paginate', :locals => { :collection => collection, :page_var => options[:page_var]}
  end

  #faster pagination http://www.igvita.com/blog/2006/09/10/faster-pagination-in-rails/
  def windowed_pagination_links(pagingEnum, options)
    link_to_current_page = options[:link_to_current_page]
    always_show_anchors = options[:always_show_anchors]
    padding = options[:window_size]

    current_page = pagingEnum.page
    html = ''

    #Calculate the window start and end pages
    padding = padding < 0 ? 0 : padding
    first = pagingEnum.page_exists?(current_page  - padding) ? current_page - padding : 1
    last = pagingEnum.page_exists?(current_page + padding) ? current_page + padding : pagingEnum.last_page

    # Print start page if anchors are enabled
    html << yield(1) if always_show_anchors and not first == 1

    # Print window pages
    first.upto(last) do |page|
     (current_page == page && !link_to_current_page) ? html << page : html << yield(page)
    end

    # Print end page if anchors are enabled
    html << yield(pagingEnum.last_page) if always_show_anchors and not last == pagingEnum.last_page
    html
  end

  def is_admin?
    current_user && current_user.admin
  end

  def other_projects
    current_user.projects.select { |p| p != @project }
  end

  def long_date(date)
    date.strftime('%A %B %d %Y')
  end

  def short_date(date)
    date.strftime('%a %b %d, %y')
  end

  def numeric_date(date)
    date.strftime('%m/%d/%Y')
  end

  def top_menu
    main_menu_links [
      (@project ? main_menu_link('Dashboard', project_dashboard_path(@project)) : main_menu_link('Overview', dashboards_path)),
      main_menu_link('Users', users_path),
      main_menu_link('Projects', projects_path),
    ]
  end

  def main_menu
    main_menu_links [
      main_menu_link('Dashboard', project_dashboard_path(@project)),
      main_menu_link('Releases', project_releases_path(@project)),
      main_menu_link('Iterations', project_iterations_path(@project)),
      main_menu_link('Backlog', project_stories_path(@project)),
      main_menu_link('Initiatives', project_initiatives_path(@project)),
      main_menu_link('Acceptance Tests', project_acceptancetests_path(@project)),
      main_menu_link('Milestones', project_milestones_path(@project)),
      main_menu_link('Team', team_project_path(@project)),
      main_menu_link('Stats', project_stats_path(@project))
    ]
  end

  def main_menu_link(title, url)
    html_options = current_page?(url) ? { 'class' => 'current' } : {}
    link_to(title,url,html_options)
  end

  def main_menu_links(urls)
    content_tag(:ul, :id => "MainMenu") do
      urls.inject(""){|lis, url| lis << content_tag(:li, url)}
    end
  end

end
