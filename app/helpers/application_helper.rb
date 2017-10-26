module ApplicationHelper
	def og_image
    #Personalise the Facebook/Twitter image for posts
    if @og_image.nil?
      return "https://farm9.staticflickr.com/8026/7254508562_25fc4962e5_b.jpg"
    else
      return @og_image
   end 
  end 

  def og_title
    #Personalise the Facebook/Twitter title
    if @og_title.nil?
      return "Steve and Glo's travel blog. Cos working is over-rated"
    else
      return @og_title
   end 
  end
end
