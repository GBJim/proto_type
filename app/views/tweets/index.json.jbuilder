json.array!(@tweets) do |tweet|
  json.extract! tweet, :id, :body, :lon, :lat, :date, :emotion
  json.url tweet_url(tweet, format: :json)
end
