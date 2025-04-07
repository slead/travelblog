require 'test_helper'

class FlickrTest < ActiveSupport::TestCase
  test "should access flickr album" do
    flickr = Flickr.new(ENV['FLICKR_API_KEY'], ENV['FLICKR_SHARED_SECRET'])
    
    # Test photoset info
    photoset = flickr.photosets.getInfo(photoset_id: "72177720324909924")
    assert photoset.present?, "Should get photoset info"
    puts "Photoset title: #{photoset.title}"
    
    # Test getting photos
    photos = flickr.photosets.getPhotos(photoset_id: "72177720324909924")
    assert photos.photo.present?, "Should get photos from album"
    puts "Number of photos: #{photos.photo.size}"
    
    # Test first photo
    first_photo = photos.photo.first
    photo_info = flickr.photos.getInfo(photo_id: first_photo.id)
    puts "First photo title: #{photo_info.title}"
    
    # Test photo sizes
    photo_sizes = flickr.photos.getSizes(photo_id: first_photo.id)
    assert photo_sizes.present?, "Should get photo sizes"
    puts "Available sizes: #{photo_sizes.map(&:label).join(', ')}"
  end
end 