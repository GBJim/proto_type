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
  	columns = [:body, :emotion, :lon, :lat, :date]
  	values = []
  	f = Roo::CSV.new "/home/gb/Downloads/prod_classified",csv_options:{col_sep:"\t"}
  	f.each do |data|
  		values.push [data[0],data[1],data[4],data[5],data[6]]
  	end
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