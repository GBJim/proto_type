class Tweet < ActiveRecord::Base


	def self.start_date
		self.minimum("date")
	end

	def self.end_date
		self.maximum("date")
	end


	def self.all_emotions
		emotions = self.group("emotion").count
		emotions.default = 0
		emotions
	end

	def self.emotions_ratio
		sum = self.count.to_f
		ratio = self.all_emotions
		ratio.update(ratio){|key,v1,v2|v1/sum}
	end


	

	def self.daily_emotion_count
		self.group("emotion").group("date").count

	end

end
