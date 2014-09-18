class Question < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
  has_many :votes

  validates_presence_of :question

  def upvotes
    votes.upvotes.count
  end

  def downvotes
    votes.downvotes.count
  end
end
