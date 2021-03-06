json.array!(@flights) do |flight|
  json.extract! flight, :id, :airlineCode, :gate, :number, :city, :adi, :scheduled, :terminal, :delay, :created_at, :updated_at
  json.url flight_url(flight, format: :json)
end
