class Event < ActiveRecord::Base
  has_many :questions
end
