class Post < ApplicationRecord
  validates :title, presence: true
	extend FriendlyId
	friendly_id :title, use: :slugged
  # searchkick
  has_and_belongs_to_many :photos

  def should_generate_new_friendly_id?
    title_changed?
  end

  before_save -> do
    # Allow override of the published date, otherwise use the current date
    if !self.published_date.present?
      self.published_date = self.created_at
    end

    # Attach Flickr photos to this post if specified as flickr_album
    begin
      if self.flickr_album.present?
        Rails.logger.info "Processing Flickr album: #{self.flickr_album}"
        photoset_id = self.flickr_album
        
        # Initialize Flickr with authentication
        require 'oauth'
        require 'json'
        
        consumer = OAuth::Consumer.new(
          ENV['FLICKR_API_KEY'],
          ENV['FLICKR_SHARED_SECRET'],
          site: 'https://www.flickr.com',
          request_token_path: '/services/oauth/request_token',
          access_token_path: '/services/oauth/access_token',
          authorize_path: '/services/oauth/authorize'
        )
        
        access_token = OAuth::AccessToken.new(
          consumer,
          ENV['FLICKR_ACCESS_TOKEN'],
          ENV['FLICKR_ACCESS_SECRET']
        )
        
        # Get photoset info first to verify access
        begin
          response = access_token.get("https://api.flickr.com/services/rest/?method=flickr.photosets.getInfo&photoset_id=#{photoset_id}&format=json&nojsoncallback=1")
          photoset_info = JSON.parse(response.body)
          
          if photoset_info['stat'] == 'ok'
            Rails.logger.info "Found photoset: #{photoset_info['photoset']['title']['_content']}"
          else
            Rails.logger.error "Error getting photoset info: #{photoset_info['message']}"
            raise "Failed to get photoset info: #{photoset_info['message']}"
          end
        rescue => e
          Rails.logger.error "Error getting photoset info: #{e.message}"
          raise
        end

        # Get photos from the photoset
        begin
          response = access_token.get("https://api.flickr.com/services/rest/?method=flickr.photosets.getPhotos&photoset_id=#{photoset_id}&format=json&nojsoncallback=1")
          photos_data = JSON.parse(response.body)
          
          if photos_data['stat'] == 'ok'
            Rails.logger.info "Found #{photos_data['photoset']['photo'].size} photos in album"
            
            photos_data['photoset']['photo'].each do |photo_data|
              photo_id = photo_data['id']
              Rails.logger.info "Processing photo: #{photo_id}"
              
              if (Photo.where(:flickr_id => photo_id).count == 0)
                Rails.logger.info "Creating new photo record for #{photo_id}"
                
                # Get photo info
                response = access_token.get("https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&photo_id=#{photo_id}&format=json&nojsoncallback=1")
                photo_info = JSON.parse(response.body)
                
                if photo_info['stat'] == 'ok'
                  date_taken = photo_info['photo']['dates']['taken']
                  title = photo_info['photo']['title']['_content']
                  description = photo_info['photo']['description']['_content']
                  
                  # Get photo sizes
                  response = access_token.get("https://api.flickr.com/services/rest/?method=flickr.photos.getSizes&photo_id=#{photo_id}&format=json&nojsoncallback=1")
                  sizes_data = JSON.parse(response.body)
                  
                  thumb = ''
                  small = ''
                  medium = ''
                  large = ''
                  
                  if sizes_data['stat'] == 'ok'
                    sizes_data['sizes']['size'].each do |size|
                      case size['label']
                      when 'Thumbnail'
                        thumb = size['source']
                      when 'Small'
                        small = size['source']
                      when 'Medium'
                        medium = size['source']
                      when 'Large'
                        large = size['source']
                      end
                    end
                  end
                  
                  photo = Photo.create!(
                    flickr_id: photo_id,
                    title: title,
                    description: description,
                    date_taken: date_taken,
                    thumb: thumb,
                    small: small,
                    medium: medium,
                    large: large
                  )
                  Rails.logger.info "Created photo record: #{photo.id}"
                else
                  Rails.logger.error "Error getting photo info: #{photo_info['message']}"
                  raise "Failed to get photo info: #{photo_info['message']}"
                end
              else
                photo = Photo.where(:flickr_id => photo_id).first
                Rails.logger.info "Found existing photo record: #{photo.id}"
              end
              
              if not self.photos.exists?(photo.id)
                self.photos << photo
                Rails.logger.info "Added photo #{photo.id} to post"
              end
            end
          else
            Rails.logger.error "Error getting photos: #{photos_data['message']}"
            raise "Failed to get photos: #{photos_data['message']}"
          end
        rescue => e
          Rails.logger.error "Error processing photos: #{e.message}"
          raise
        end
      end
    rescue => e
      Rails.logger.error "Error in Flickr album processing: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      # Re-raise the error to prevent the save
      raise
    end
  end

	geocoded_by :placename
	reverse_geocoded_by :latitude, :longitude do |obj, results|
    if geo = results.first
      obj.city = geo.city
      obj.state = geo.state
      obj.country = geo.country
    end
  end
  after_validation :geocode, if: :placename_changed?
  after_validation :reverse_geocode, if: :placename_changed?

  def next
    Post.where("published_date > ?", published_date).where("status = 'published'").order("published_date ASC").first
  end

  def previous
    Post.where("published_date < ?", published_date).where("status = 'published'").order("published_date DESC").first
  end

  def unique_photos
    photos.distinct.order(:sort)
  end

  def deduplicate_photos!
    # Get unique photo IDs while preserving order
    unique_photo_ids = photos.order(:sort).pluck(:id).uniq
    
    # Clear existing associations
    photos.clear
    
    # Re-add photos in order, ensuring no duplicates
    unique_photo_ids.each_with_index do |photo_id, index|
      photo = Photo.find(photo_id)
      photo.update(sort: index)
      photos << photo
    end
  end

end
