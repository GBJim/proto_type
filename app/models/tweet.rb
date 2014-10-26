class Tweet < ActiveRecord::Base

	reverse_geocoded_by :lat, :lon, :lookup => :yandex
	after_validation :reverse_geocode

	def geo
		Geocoder.search([self.lat,self.lon]).first
	end

	def self.start_date
		self.minimum("date")
	end

	def self.end_date
		self.maximum("date")
	end


	def self.all_emotions
		emotions = self.group("emotion").count(:id)
		emotions.default = 0
		emotions
	end

	def self.emotions_ratio
		sum = self.count(:id).to_f
		ratio = self.all_emotions
		result = {}
		#ratio.update(ratio){|key,v1,v2|v1/sum}
		['sadness','trust','anger','joy','disgust','fear','anticipation','surprise'].each do |emotion|
 			result[emotion] = ratio[emotion]/sum
		end
		result
	end


	

	def self.daily_emotion_count
		self.group("emotion").group("date").count(:id)

	end

end
