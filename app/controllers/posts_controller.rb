class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  include ActionView::Helpers::DateHelper

  rescue_from ActiveRecord::RecordNotFound do
    flash[:notice] = "Sorry, that post does not exist"
    redirect_to action: :index
  end

  # GET /posts
  # GET /posts.json
  # def index
  #   @posts = Post.paginate(:page => params[:page], :per_page => 3).order published_date: :desc
  # end

  def index
    if params[:bbox].present?
      #Find posts which fall within the current map extent
      bbox = params[:bbox].split(",").map(&:to_f)
      @posts = Post.within_bounding_box(bbox).order(:title)
    elsif params[:id].present?
      # This path is called when the user chooses an Ignite from the dropdown on the Posts page. In
      # this case, open that post's homepage (and break out of the rest of this function)
      @post = Post.find(params[:id])
      redirect_to @post
      return
    else
      @posts = Post.paginate(:page => params[:page], :per_page => 3).order published_date: :desc
      @posts.first.hero_image_url.present? ? @header_image_url = @posts.first.hero_image_url : @header_image_url = 'img/home-bg.jpg'
    end
    # Make a JSON object from the posts, to add to the map
    @geojson = Array.new

    @posts.each do |post|
      @geojson << {
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: [post.longitude, post.latitude]
        },
        properties: {
          title: post.title,
          url: post.slug
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
      params.require(:post).permit(:title, :content, :placename, :published_date, :hero_image_url)
    end
end
