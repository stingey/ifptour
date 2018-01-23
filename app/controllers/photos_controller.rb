class PhotosController < ApplicationController
  def index
    @photos = Photo.order(created_at: :desc)
  end

  def new
    @photo = Photo.new
  end

  def show
    @photo = Photo.find(params[:id])
  end

  def create
    puts "\n\n\n#{params.inspect}\n\n\n"
    @photo = Photo.new(photo_params)
    if @photo.save
      redirect_to photos_path
    else
      redirect_to root_path
    end
  end

  def update
    @photo = Photo.find(params[:id])
    if @photo.update_attributes(photo_params)
      redirect_to photos_path
    else
      render :edit
    end
  end

  private

  def photo_params
    params.require(:photo).permit(:image)
  end
end
