class RankingDetail < ApplicationRecord
  RANKS_HASH = {
    junior_amateur: [200, 499],
    junior_pro: [500, 298],
    new_player: [799, 799],
    beginner: [800, 999],
    rookie: [1000, 1499],
    amateur: [1500, 1999],
    expert: [2000, 2999],
    pro: [3000, 4999],
    master: [5000, 1000000]
              }.freeze

  RANKS = %w(master pro expert amateur rookie beginner new_player junior_pro junior_amateur).freeze

  belongs_to :player

  after_save :set_rank

  validates :singles_points, presence: true
  validates :doubles_points, presence: true
  validates :womens_singles_points, presence: true, if: :female?
  validates :womens_doubles_points, presence: true, if: :female?

  private

  def female?
    player.gender == "F"
  end

  def set_rank
    RANKS_HASH.each do |rank, range|
      update_column(:singles_rank, rank.to_s.humanize) if singles_points&.between?(range.first, range.last)
      update_column(:doubles_rank, rank.to_s.humanize) if doubles_points&.between?(range.first, range.last)
      update_column(:womens_singles_rank, rank.to_s.humanize) if womens_singles_points&.between?(range.first, range.last)
      update_column(:womens_doubles_rank, rank.to_s.humanize) if womens_doubles_points&.between?(range.first, range.last)
    end
  end
end
