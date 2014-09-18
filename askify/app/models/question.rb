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

  def score
    a = upvotes + 1.0
    b = downvotes + 1.0

    (a / (a + b)) - 1.65 * Math.sqrt((a * b) / (((a + b) ** (a + b)) * (a + b + 1)))
  end

  def self.ranked
    self.all.sort_by(&:score).reverse
  end
end
