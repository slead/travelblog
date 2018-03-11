class TipsController < ApplicationController
  before_action :set_tip, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:create, :new, :edit, :update, :destroy]

  include ActionView::Helpers::DateHelper

  rescue_from ActiveRecord::RecordNotFound do
    flash[:notice] = "Sorry, that tip does not exist"
    redirect_to action: :index
  end

  def index
    if params[:id].present?
      @tip = Tip.find(params[:id])
      redirect_to @tip
      return
    elsif params[:category].present?
      @tips = Tip.where(category: params[:category]).paginate(:page => params[:page], :per_page => 3).order created_at: :desc
    else
      @tips = Tip.paginate(:page => params[:page], :per_page => 3).order created_at: :desc
    end
    @header_image_url = 'https://farm9.staticflickr.com/8026/7254508562_25fc4962e5_b.jpg'

    respond_to do |format|
      format.html
    end
  end

  # GET /tips/1
  # GET /tips/1.json
  def show
    @tip = Tip.friendly.find(params[:id])
    @meta = "Published #{time_ago_in_words(@tip.created_at)} ago"
    if @tip.category.present?
      @meta += " in " + @tip.category.titlecase
    end
    @og_title = @tip.title
  end

  # GET /tips/new
  def new
    @tip = Tip.new
  end

  # GET /tips/1/edit
  def edit
  end

  # POST /tips
  # POST /tips.json
  def create
    @tip = Tip.new(tip_params)

    respond_to do |format|
      if @tip.save
        format.html { redirect_to @tip, notice: 'Tip was successfully created.' }
        format.json { render :show, status: :created, location: @tip }
      else
        format.html { render :new }
        format.json { render json: @tip.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tips/1
  # PATCH/PUT /tips/1.json
  def update
    respond_to do |format|
      if @tip.update(tip_params)
        format.html { redirect_to @tip, notice: 'Tip was successfully updated.' }
        format.json { render :show, status: :ok, location: @tip }
      else
        format.html { render :edit }
        format.json { render json: @tip.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tips/1
  # DELETE /tips/1.json
  def destroy
    @tip.destroy
    respond_to do |format|
      format.html { redirect_to tips_url, notice: 'Tip was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tip
      @tip = Tip.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tip_params
      params.require(:tip).permit(:title, :content, :created_at, :category)
    end

end
