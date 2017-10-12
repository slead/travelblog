class ContentController < ApplicationController
  
  def show
    render content_params[:content]
  end

  def home
    respond_to :html
  end

  def content_params
    params.permit :content
  end
end