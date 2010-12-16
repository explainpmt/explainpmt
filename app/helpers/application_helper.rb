module ApplicationHelper
  
  VERSION = 'dev trunk'
  
  def create_action_option(text, href, options={})
    options[:method] = :get unless options[:method]
    qParams = options.to_a.collect!{|k,v| "#{k}=#{v}"}.join("&")
    content_tag("option", text, :value => "#{href}?#{qParams}")
  end
  
  def column_content_for(cols, column, &block)
    yield unless cols.include?(column)
  end
  
  def nav_item(text,url,current=false)
    current ||= current_page?(url)
    "<li>"+link_to(text, url, :class => (current ? 'current' : ''))+"</li>"
  end
  
  def long_date(date)
    date.strftime('%A %B %d %Y')
  end

  def short_date(date)
    date.strftime('%a %b %d, %y')
  end

  def relative_date(date)
    'about ' + time_ago_in_words(date) + ' ago'
  end

  def numeric_date(date)
    date.strftime('%m/%d/%Y')
  end
  
  def medium_date(date)
    date.strftime('%B %d, %Y')
  end
  
end
