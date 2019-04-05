class Player < ApplicationRecord
  paginates_per 50
  has_one :ranking_detail, dependent: :destroy

  accepts_nested_attributes_for :ranking_detail, allow_destroy: true

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :gender, presence: true

  scope :female, -> { where(gender: 'F') }
  scope :male, -> { where(gender: 'M') }

  def full_name
    "#{first_name.capitalize} #{last_name.capitalize}"
  end
end
