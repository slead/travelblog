class Post < ApplicationRecord
  validates :title, presence: true
	extend FriendlyId
	friendly_id :title, use: :slugged

  has_and_belongs_to_many :photos

  def should_generate_new_friendly_id?
    title_changed?
  end

  before_create -> do
    # Allow override of the published date, otherwise use the current date
    if !self.published_date.present?
      self.published_date = self.created_at
    end
  end

	geocoded_by :placename
	reverse_geocoded_by :latitude, :longitude do |obj, results|
    if geo = results.first
      obj.city = geo.city
      obj.state = geo.state
      obj.country = geo.country
    end
  end
  after_validation :geocode, if: :placename_changed?
  after_validation :reverse_geocode, if: :placename_changed?

  def previous
    Post.where(["id < ?", id]).last
  end

  def next
    Post.where(["id > ?", id]).first
  end

end
