class Post < ApplicationRecord
  validates :title, presence: true
	extend FriendlyId
	friendly_id :title, use: :slugged
  searchkick
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
        photoset_id = self.flickr_album
        flickr.photosets.getPhotos(photoset_id: photoset_id).photo.map do |photo|
          photo_id = photo['id']
          if (Photo.where(:flickr_id => photo_id).count == 0)
            photo_info = flickr.photos.getInfo :photo_id => photo_id
            date_taken = photo_info['dates']['taken']
            title = photo_info['title']
            description = photo_info['description']
            photo_sizes = flickr.photos.getSizes :photo_id => photo_id
            thumb = ''
            small = ''
            medium = ''
            large = ''
            photo_sizes.each do |size|
              label = size['label']
              if label == 'Thumbnail'
                thumb = size['source']
              elsif label == 'Small'
                small = size['source']
              elsif label == 'Medium'
                medium = size['source']
              elsif label == 'Large'
                large = size['source']
              end
            end
            photo = Photo.create!(flickr_id: photo_id, title: title, description: description, date_taken: date_taken, thumb: thumb, small: small, medium: medium, large: large)
          else
            photo = Photo.where(:flickr_id => photo_id).first
          end
          if not self.photos.exists?(photo.id)
            self.photos << photo
          end
        end
      end
    rescue
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

end
