class RankingDetail < ApplicationRecord
  RANKS_HASH = {beginner: [800, 999],
                rookie: [1000, 1499],
                amateur: [1500, 1999],
                expert: [2000, 2999],
                pro: [3000, 4999],
                master: [5000, 9000]}.freeze

  belongs_to :player

  after_save :set_rank

  private

  def set_rank
    RANKS_HASH.each do |rank, range|
      update_column(:singles_rank, rank.to_s) if singles_points&.between?(range.first, range.last)
      update_column(:doubles_rank, rank.to_s) if doubles_points&.between?(range.first, range.last)
      update_column(:womens_singles_rank, rank.to_s) if womens_singles_points&.between?(range.first, range.last)
      update_column(:womens_doubles_rank, rank.to_s) if womens_doubles_points&.between?(range.first, range.last)
    end
  end
end
