class ContentController < ApplicationController
  
  def show
    render content_params[:content]
  end

  def home
    respond_to :html
  end

  def locations
    @posts = Post.where(status: 'published')
                .where.not(latitude: nil)
                .order(:country, :city)
    
    # Group posts by country and city
    @posts_by_location = @posts.group_by(&:country).transform_values do |country_posts|
      country_posts.group_by(&:city)
    end
  end

  def content_params
    params.permit :content
  end
end