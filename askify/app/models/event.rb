class Event < ActiveRecord::Base
  has_many :questions
  belongs_to :user

  validates_presence_of :name
end
