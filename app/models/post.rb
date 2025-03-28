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
    if self.flickr_album.present? # Removed the _changed? condition for testing
      begin
        Rails.logger.info "Fetching photos from Flickr album: #{self.flickr_album}"
        photoset_id = self.flickr_album
        
        # Get all photos from the album
        Rails.logger.info "Calling flickr.photosets.getPhotos..."
        photoset = flickr.photosets.getPhotos(
          photoset_id: photoset_id,
          user_id: ENV['FLICKR_USER_ID']
        )
        Rails.logger.info "Photoset response: #{photoset.inspect}"
        
        if photoset && photoset.photo.present?
          photoset.photo.each do |photo|
            photo_id = photo['id']
            Rails.logger.info "Processing photo: #{photo_id}"
            Rails.logger.info "Photo data: #{photo.inspect}"
            
            # Skip if photo already exists in this post
            next if self.photos.exists?(flickr_id: photo_id)
            
            # Get or create the photo
            existing_photo = Photo.find_by(flickr_id: photo_id)
            
            if existing_photo
              Rails.logger.info "Using existing photo: #{photo_id}"
              self.photos << existing_photo unless self.photos.exists?(id: existing_photo.id)
              next
            end

            begin
              photo_sizes = flickr.photos.getSizes(photo_id: photo_id)
              Rails.logger.info "Photo sizes response: #{photo_sizes.inspect}"
            rescue => e
              Rails.logger.error "Error getting photo sizes: #{e.message}"
              next
            end
            
            # Extract URLs for different sizes
            urls = {}
            photo_sizes.each do |size|
              case size['label']
              when 'Square'
                urls[:thumb] = size['source']
              when 'Small'
                urls[:small] = size['source']
              when 'Medium'
                urls[:medium] = size['source']
              when 'Large'
                urls[:large] = size['source']
              end
            end

            # Construct Flickr URLs if sizes not found
            if urls.empty?
              farm_id = photo['farm']
              server_id = photo['server']
              secret = photo['secret']
              base_url = "https://farm#{farm_id}.staticflickr.com/#{server_id}/#{photo_id}_#{secret}"
              urls[:thumb] = "#{base_url}_s.jpg"  # 75x75
              urls[:small] = "#{base_url}_n.jpg"  # 320 on longest side
              urls[:medium] = "#{base_url}.jpg"   # 500 on longest side
              urls[:large] = "#{base_url}_b.jpg"  # 1024 on longest side
            end

            begin
              # Create new photo record
              new_photo = Photo.create!(
                flickr_id: photo_id,
                title: photo['title'] || 'Untitled',
                description: '',
                date_taken: Time.current,
                thumb: urls[:thumb],
                small: urls[:small],
                medium: urls[:medium],
                large: urls[:large]
              )

              Rails.logger.info "Created new photo: #{photo_id}"
              self.photos << new_photo
            rescue => e
              Rails.logger.error "Error creating photo: #{e.message}"
              next
            end
          end

          Rails.logger.info "Successfully synced #{photoset.photo.size} photos from Flickr album"
        else
          Rails.logger.warn "No photos found in Flickr album: #{photoset_id}"
        end
      rescue => e
        Rails.logger.error "Error syncing Flickr photos: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        raise
      end
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
