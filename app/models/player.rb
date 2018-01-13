class Player < ApplicationRecord
  RANKS_HASH = {beginner: [800, 999],
                rookie: [1000, 1499],
                amateur: [1500, 1999],
                expert: [2000, 2999],
                pro: [3000, 4999],
                master: [5000, 9000]}.freeze

  has_one :ranking_detail

  accepts_nested_attributes_for :ranking_detail, allow_destroy: true

  # after_commit :set_rank

  # def set_rank
    # RANKS_HASH.each do |rank, range|
    #   ranking_detail.singles_rank = rank.to_s if self.ranking_detail.singles_points.between?(range.first, range.last)
    #   ranking_detail.doubles_rank = rank.to_s if ranking_detail.doubles_points.between?(range.first, range.last)
    #   ranking_detail.womens_singles_rank = rank.to_s if ranking_detail.womens_singles_points.between?(range.first, range.last)
    #   ranking_detail.womens_doubles_rank = rank.to_s if ranking_detail.womens_doubles_points.between?(range.first, range.last)
    # end
  # end

  def rank_singles
    RANKS_HASH.each do |rank, range|
      return rank.to_s if ranking_detail.singles_points.between?(range.first, range.second)
    end
    nil
  end

  def rank_doubles
    RANKS_HASH.each do |rank, range|
      return rank.to_s if ranking_detail.doubles_points.between?(range.first, range.second)
    end
    nil
  end
end
