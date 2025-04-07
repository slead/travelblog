class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  before_action :initialize_flickr
  
  private
  
  def initialize_flickr
    @flickr = Flickr.new(ENV['FLICKR_API_KEY'], ENV['FLICKR_SHARED_SECRET'])
  end
end
