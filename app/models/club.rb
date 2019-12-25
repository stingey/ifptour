class Club < ApplicationRecord

  validates :name, presence: true
  validates :city, presence: true
  validates :state, presence: true

  has_many :local_tournaments, inverse_of: :club
  accepts_nested_attributes_for :local_tournaments, allow_destroy: true

  def frequent_participants
    participants = local_tournaments.pluck(:participants).flatten.map(&:downcase)
    participants = participants.select { |element| participants.count(element) > 1 }
    participants.uniq
  end
end
