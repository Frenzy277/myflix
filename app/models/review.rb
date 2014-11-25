class Review < ActiveRecord::Base
  belongs_to :user
  belongs_to :video

  validates_presence_of :body, :rating
  validates_inclusion_of :rating, in: 1..5
end