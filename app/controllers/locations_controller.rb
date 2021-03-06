class LocationsController < ApplicationController
  skip_before_action :authenticate_user!, only: :index
  skip_after_action :verify_authorized, only: :dashboard

  def index
    @locations = policy_scope(Location)
    @locations = Location.all
    @locations = Location.where.not(latitude: nil, longitude: nil)
    @favorite = Favorite.new

    if params[:search].present?
      @locations = Location.search_by_name_and_description_and_category_and_address(params[:search]).order('created_at DESC')
    else
      @locations = Location.all
    end

    @markers = @locations.map do |location| {
      lat: location.latitude,
      lng: location.longitude,
      infoWindow: render_to_string(partial: "infowindow", locals: { location: location })
    }
    end
  end

  def dashboard
    @locations = current_user.locations
    @bookings = current_user.bookings
    # authorize @location
  end

  def new
    @location = Location.new
    authorize @location
  end

  def create
    @location = Location.new(location_params)
    @location.user = current_user
    authorize @location
    if @location.save!
      redirect_to location_path(@location)
    else
      render 'new'
    end
  end

  def show
    @location = Location.find(params[:id])
    @booking = Booking.new
    authorize @location

    @markers = [{
        lat: @location.latitude,
        lng: @location.longitude,
        infoWindow: render_to_string(partial: "infowindow", locals: { location: @location })
      }]
  end

  def edit
    @location = Location.find(params[:id])
    authorize @location
  end

  def update
    @location = Location.find(params[:id])
    @location.update(location_params)
    authorize @location
    redirect_to location_path(@location)
  end

  def destroy
    @location = Location.find(params[:id])
    @location.destroy
    authorize @location
    redirect_to dashboard_path
  end

  private

  def location_params
    params.require(:location).permit(:name, :address, :category, :description, :price, :photo)
  end

  def article_params
    params.require(:article).permit(:title, :body, :photo)
  end
end
