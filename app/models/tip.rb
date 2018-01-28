class Tip < ApplicationRecord
  validates :title, presence: true
	extend FriendlyId
	friendly_id :title, use: :slugged
  # searchkick

  def should_generate_new_friendly_id?
    title_changed?
  end

  before_save -> do
  end

  def next
    Tip.where("created_at > ?", created_at).order("created_at ASC").first
  end

  def previous
    Tip.where("created_at < ?", created_at).order("created_at DESC").first
  end

end
