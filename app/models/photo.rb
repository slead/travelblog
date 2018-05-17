class Photo < ApplicationRecord
  has_and_belongs_to_many :posts
  include RailsSortable::Model
  set_sortable :sort  # Indicate a sort column
  # If you do NOT want timestamps to be updated on sorting, use the following option.
  set_sortable :sort, without_updating_timestamps: true
end
