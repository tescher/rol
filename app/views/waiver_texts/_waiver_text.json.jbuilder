json.extract! waiver_text, :id, :filename, :data, :type, :created_at, :updated_at
json.url waiver_text_url(waiver_text, format: :json)
