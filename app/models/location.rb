class Location < ApplicationRecord
  mount_uploader :photo, PhotoUploader
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  CATEGORY = ["landscape", "urban", "field", "beach", "plain"]

  belongs_to :user
  has_many :bookings, dependent: :destroy
  has_many :favorites, dependent: :destroy

  validates :name, presence: true
  validates :address, presence: true
  validates :price, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORY }
  validates :description, presence: true

  def self.search(search)
    where("name ILIKE ?", "%#{search}%")
  end

  include PgSearch
  pg_search_scope :search_by_name_and_description_and_category_and_address,
  against: [:name, :description, :category, :address],
     using: {
      tsearch: { prefix: true }
    }
end
