require 'flickraw'

FlickRaw.api_key = ENV['FLICKR_API_KEY']
FlickRaw.shared_secret = ENV['FLICKR_SHARED_SECRET']

# Configure for public access only (no authentication needed for public photos)
flickr.access_token = nil
flickr.access_secret = nil 