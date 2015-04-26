json.array!(@manage_applications) do |manage_application|
  json.extract! manage_application, :name
  json.url manage_application_url(manage_application, format: :json)
end
