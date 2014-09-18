class EventsController < ApplicationController
  before_action :set_event, only: :show
  before_action :authenticate_user!, only: [:new, :create]

  # GET /events
  def index
    @events = Event.all
  end

  # GET /events/1
  def show
    @questions = @event.questions
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # POST /events
  def create
    @event = Event.new(event_params)

    if @event.save
      redirect_to @event, notice: 'Event was successfully created.'
    else
      render :new
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def event_params
      params.require(:event).permit(:name).merge(user_id: current_user.id)
    end
end
