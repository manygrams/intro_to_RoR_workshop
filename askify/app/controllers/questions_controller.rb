class QuestionsController < ApplicationController
  before_action :set_question, only: :show
  before_action :set_event, only: [:new, :create]

  # GET /questions/1
  def show
  end

  # GET /questions/new
  def new
    @event = Event.find(params[:event_id])
    @question = Question.new
  end

  # POST /questions
  def create
    @question = Question.new(question_params)

    if @question.save
      redirect_to @event, notice: 'Question was successfully created.'
    else
      render :new
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def question_params
      params.require(:question).permit(:question).merge(event_id: params[:event_id])
    end

    def set_event
      @event = Event.find(params[:event_id])
    end
end
