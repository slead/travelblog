json.extract! photo, :id, :flickr_id, :title, :description, :date_taken, :thumb, :small, :medium, :large, :created_at, :updated_at
json.url photo_url(photo, format: :json)
