json.extract! contact, :id, :date_time, :contact_method_id, :volunteer_id, :notes, :created_at, :updated_at
json.url contact_url(contact, format: :json)
