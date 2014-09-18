class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :question

  validates_uniqueness_of :user, scope: :question, message: "can only vote once per question!"

  scope :upvotes, ->{ where(score: "upvote") }
  scope :downvotes, ->{ where(score: "downvote") }
end
