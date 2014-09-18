class VotesController < ApplicationController
  before_action :load_question, :create_vote

  def upvote
  end

  def downvote
  end

  private

  def load_question
    @question = Question.find(params[:id])
  end

  def create_vote
    @question.votes.create!(user_id: current_user.id, score: action_name)
    redirect_to @question.event, notice: "#{action_name} created!"
  end
end
