class GetpinsController < ApplicationController
  def index
    # Cache the entire response for 1 hour
    @geojson = Rails.cache.fetch('map_pins', expires_in: 1.hour) do
      # Eager load photos to avoid N+1 queries
      posts = Post.includes(:photos)
                 .where("latitude IS NOT NULL AND status = ?", "published")
                 .order(published_date: :desc)
      
      Rails.logger.debug "Found #{posts.count} posts with coordinates"
      
      # Build the GeoJSON response
      posts.map do |post|
        {
          type: 'Feature',
          geometry: {
            type: 'Point',
            coordinates: [post.longitude, post.latitude]
          },
          properties: {
            title: post.title,
            url: "/posts/#{post.slug}",
            photo: post.photos.any? ? post.photos.order(:sort).first.small : nil
          }
        }
      end
    end

    respond_to do |format|
      format.html
      format.json { render json: @geojson }
    end
  end
end
