namespace :dev do
  desc "Import sample tweets data"
  task :import => :environment do
    f = Roo::CSV.new "/home/gb/Downloads/prod_classified",csv_options:{col_sep:"\t"}
    f.each do |data|
      x = Tweet.new(body:data[0],lon:data[4],lat:data[5], emotion:data[1], date: data[6] )
      x.save
    end
  end
  desc "fast import"
  task :fastImport => :environment do
  	columns = [:body, :lon, :lat, :date, :emotion]
  	values = []

  	f = File.open("/home/gb/research/Emotional_GodenGlobes_tweets.tsv")
    f.readline()
  	f.each_line do |line| 
    
      row = line.split("\t")
      next if row.length != 6
      text = row[0]
      lon = row[1]
      lat = row[2]
      date = row[3]
      emotion = row[4]
  		values.push [text, lon, lat, date, emotion]
     
  	end
    puts "Here"
  	Tweet.import columns, values
  end

  desc "assign address"
  task :address => :environment do
    Tweet.where(address:nil).each do |t|
      t.address = t.reverse_geocode
      t.save
    end
  end

  desc "show all locations"
  task :coordinate => :environment do
    Tweet.all.each do |t|
    puts "#{t.lat},#{t.lon}"
    end
  end


end