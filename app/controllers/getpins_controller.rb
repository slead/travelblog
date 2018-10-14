class GetpinsController < ApplicationController
  def index
    @posts = Post.where(["latitude IS NOT NULL and status= ?", "published"]).order published_date: :desc

    # Make a JSON object from the posts, to add to the map
    @geojson = Array.new
    @posts.each do |post|
      post.photos.count > 0 ? photo = post.photos.order(:sort).first.small : photo = nil
      @geojson << {
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: [post.longitude, post.latitude]
        },
        properties: {
          title: post.title,
          url: "/posts/" + post.slug,
          photo: photo
        }
      }
    end
    respond_to do |format|
      format.html
      # Format the response for the map
      format.json { render json: @geojson }
    end
  end
end
