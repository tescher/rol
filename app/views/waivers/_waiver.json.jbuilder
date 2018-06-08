json.extract! waiver, :id, :volunteer_id, :guardian_id, :over_18, :birthdate, :date_signed, :waiver_text, :e_sign, :created_at, :updated_at
json.url waiver_url(waiver, format: :json)
