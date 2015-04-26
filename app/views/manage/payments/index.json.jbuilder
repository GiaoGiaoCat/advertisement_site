json.array!(@manage_payments) do |manage_payment|
  json.extract! manage_payment, 
  json.url manage_payment_url(manage_payment, format: :json)
end
