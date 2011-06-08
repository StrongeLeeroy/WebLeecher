module ApplicationHelper
  
  def logo
    image_tag("logo.png", :alt => "Sample App", :class => "round")
  end

  #Return a title on a per-page basis.
  def title
    base_title = "Lethalia RoR Sample App"
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end 
end
