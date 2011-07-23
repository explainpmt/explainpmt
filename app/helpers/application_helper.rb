module ApplicationHelper
  
  VERSION = 'dev trunk'
  
  def create_action_option(text, value, options={})
    options[:method] = :get unless options[:method]
    content_tag("option", text, :value => "#{href}?#{options.to_query}")
  end
  
  def column_content_for(cols, column, &block)
    # yield unless cols.include?(column)
    with_output_buffer(&block) unless cols.include?(column)
  end
  
  def nav_item(text,url,current=false)
    current ||= current_page?(url)
    "<li>"+link_to(text, url, :class => (current ? 'active' : ''))+"</li>"
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
  
  def medium_date(date)
    date.strftime('%B %d, %Y')
  end
  
end
