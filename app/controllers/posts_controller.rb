class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:create, :new, :edit, :update, :destroy]

  include ActionView::Helpers::DateHelper

  rescue_from ActiveRecord::RecordNotFound do
    flash[:notice] = "Sorry, that post does not exist"
    redirect_to action: :index
  end

  def index
    # if params[:query].present?
    #   # Find posts using elastic search
    #   @posts = Post.where("status = 'published'").search(params[:query], page: params[:page], :per_page => 10)
    if params[:map].present?
      @posts = Post.where(["latitude IS NOT NULL and status= ?", "published"]).order published_date: :desc
    elsif params[:id].present?
      # This path is called when the user chooses an Ignite from the dropdown on the Posts page. In
      # this case, open that post's homepage (and break out of the rest of this function)
      @post = Post.find(params[:id])
      redirect_to @post
      return
    else
      @posts = Post.paginate(:page => params[:page], :per_page => 4).order published_date: :desc
    end
    begin
      @header_image_url = @posts.where(status: "published").first.photos.order(:sort).first.large
    rescue
      @header_image_url = 'https://farm9.staticflickr.com/8026/7254508562_25fc4962e5_b.jpg'
    end

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

  # GET /posts/1
  # GET /posts/1.json
  def show
    @post = Post.friendly.find(params[:id])
    @meta = "Posted #{time_ago_in_words(@post.published_date)} ago"
    if @post.city && @post.country
      @meta += " in #{@post.city}, #{@post.country}"
    end
    if @post.photos.count > 0
      @og_image = @post.photos.order(:sort).first.large
    end
    @og_title = @post.title
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def post_params
      params.require(:post).permit(:title, :content, :placename, :published_date, :flickr_album, :status)
    end

end
