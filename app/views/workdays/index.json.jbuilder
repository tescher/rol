json.array!(@workdays) do |workday|
  json.extract! workday, :id, :description, :project_id
  json.url workday_url(workday, format: :json)
end
