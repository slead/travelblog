class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  FlickRaw.api_key = ENV['FlickRaw_api_key']
  FlickRaw.shared_secret = ENV['FlickRaw_shared_secret']
end
