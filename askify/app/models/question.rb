class Question < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
  has_many :votes

  validates_presence_of :question
end
