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
    @vote = @question.votes.new(user_id: current_user.id, score: action_name)

    if @vote.save
      flash[:notice] = "#{action_name} created!"
    else
      flash[:notice] = "Could not save vote: #{@vote.errors.full_messages.join(",")}"
    end

    redirect_to @question.event
  end
end
