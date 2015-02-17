 class TweetsController < ApplicationController
  before_action :set_tweet, only: [:show, :edit, :update, :destroy]

  # GET /tweets
  # GET /tweets.json






  def index

 
    if params[:screen_name].present?
      tweets_count = 200
      begin 
        request_params = {:count => tweets_count, :include_rt => false }
        @tweets = get_user_tweets(params[:screen_name])
      rescue
      end
     else
      @tweets = [{:id=>1, :text=>"dummy", :created_at=>123}]
    end
    @tweets = Tweet.all()

   
  end

  # GET /tweets/1
  # GET /tweets/1.json
  def emoface
    if params[:screen_name].present?
      tweets_count = 200
      
        @tweets = get_user_tweets(params[:screen_name])
        @profile_image = @tweets[0]["user"]["profile_image_url"]#.to_str.gsub("_normal","")
        emotions = tweets_to_emotions(@tweets)

        emotions_ratio = emotions_sum(emotions)
        
        @text = emotions_ratio
        gon.face = emotions_ratio.clone
        @face_feature = face_scale(emotions_ratio.clone)
        gon.disgust = @face_feature["disgust"]
        @face_feature_1 = face_scale_1(emotions_ratio.clone)
      
     else
      @tweets = [{:id=>1, :text=>"dummy", :created_at=>123}]
      @text = "Please search"
    end
   
  end




  def face
    @face_feature = face_scale(Tweet.emotions_ratio)
    render :partial => "face"
    
  end


  def chart
    #emotions_count = get_emotion
    @every_emotion = get_every_emotion
    render plain:@every_emotion
  end

  def visualization
    if params[:search].present?
      @q = Tweet.near(params[:search],20,:order => false).search(body_cont:params[:q])
    else
      @q = Tweet.search(body_cont:params[:q])
    end


    if params[:box].present?
      box = params[:box].map{|x|x.to_f}
      lon_min = [box[0],box[2]].min
      lat_min = [box[1],box[3]].min

      lon_max = [box[0],box[2]].max
      lat_max = [box[1],box[3]].max
      tweets = @q.result.where("lon < ? AND lon > ? AND lat < ? AND lat > ?",lon_max,lon_min,lat_max,lat_min)
    else
      tweets = @q.result
    end

    #tweets = @q.result



    #tweets = Tweet.where(emotion:"fear")

    @count = tweets.count(:id)
    @show_tweets = tweets.select("emotion","body").take(5)
    gon.daily_emotion = get_every_emotion(tweets)
    gon.total_emotion = get_emotion(tweets)
    gon.locations = get_locations(tweets)
    gon.face = tweets.emotions_ratio
    @face_feature = face_scale(tweets.emotions_ratio)
    gon.disgust = @face_feature["disgust"]
    @face_feature_1 = face_scale_1(tweets.emotions_ratio)
    gon.test = get_daily_emotionalCSV(tweets)


    respond_to do |format|
      format.html{}
      format.json{render json: tweets.geo_json}
    end

    
  end

  def show
  end

  # GET /tweets/new
  def new
    @tweet = Tweet.new
  end

  # GET /tweets/1/edit
  def edit
  end

  # POST /tweets
  # POST /tweets.json
  def create
    @tweet = Tweet.new(tweet_params)

    respond_to do |format|
      if @tweet.save
        format.html { redirect_to @tweet, notice: 'Tweet was successfully created.' }
        format.json { render :show, status: :created, location: @tweet }
      else
        format.html { render :new }
        format.json { render json: @tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tweets/1
  # PATCH/PUT /tweets/1.json
  def update
    respond_to do |format|
      if @tweet.update(tweet_params)
        format.html { redirect_to @tweet, notice: 'Tweet was successfully updated.' }
        format.json { render :show, status: :ok, location: @tweet }
      else
        format.html { render :edit }
        format.json { render json: @tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tweets/1
  # DELETE /tweets/1.json
  def destroy
    @tweet.destroy
    respond_to do |format|
      format.html { redirect_to tweets_url, notice: 'Tweet was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def emotions_sum(emotions)
    emotion_set = Set.new ['sadness','trust','anger','joy','disgust','fear','anticipation','surprise']
    emoHash = {}
    emoHash.default = 0
    sum = 0
    emotions.each do |emotion|
      begin
        key = emotion['groups'][0]['name']
      rescue
        next
      end
      if emotion_set.include? key
        sum += 1
        emoHash[key] += 1
      end
    end
    sum = sum.to_f
    emoHash.each do |key, value|
      emoHash[key] = value/sum
    end
    puts emoHash
    emoHash
  end

  def get_user_tweets(screen_name, tweets_count = 200)

    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = "MLGdNZCfmzGthHTAyJU4KFvbU"
      config.consumer_secret     = "Tfp7DIZcJLbnS8BR5CWQmZklrhsbtc3fMfssKPT4SZoYsPiQKw"
      config.access_token        = "2383540880-s2C8xPgA4ITF7QnLRFnHK1es2UEbmW8qHQ87sX5"
      config.access_token_secret = "kLYgBTPeslLgaFugCx0PoiBpPIKnyCBEVfqqJCkjsSKpP"
    end

    request_params = {:count => tweets_count, :include_rt => false }

    begin
    page_tweets = client.user_timeline(screen_name, request_params)

    total_tweets =  page_tweets

    while page_tweets.length >= tweets_count do
      request_params[:max_id] = page_tweets.last.id
      page_tweets = client.user_timeline(screen_name, request_params)
      total_tweets.delete_at(-1) if page_tweets.length > 0 
      total_tweets += page_tweets
    end
    return total_tweets


    rescue
    end



  end    




    # Use callbacks to share common setup or constraints between actions.
    def set_tweet
      @tweet = Tweet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tweet_params
      params.require(:tweet).permit(:body, :lon, :lat, :date, :emotion)
    end

    def tweets_to_emotions(tweets)
      emotions =[]
      tweets.each do |tweet|
        payload = {:text => tweet["text"], :lang => "en"}
        response = tweet_to_emotion({:text => tweet["text"], :lang => "en"})
        emotions <<  response
      end      
      emotions
    end

    def tweet_to_emotion(payload)
      uri = URI("http://140.114.77.14:8080/webresources/jammin/emotion")
      req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
      req.body = payload.to_json
      response = Net::HTTP.new("140.114.77.14", 8080).start {|http| http.request(req) }
      begin
        JSON.parse(response.body)
      rescue
        nil
      end
    end


    def get_daily_emotionalCSV(tweets)
      emotion_category = ['sadness','trust','anger','joy','disgust','fear','anticipation','surprise']
      start_date = tweets.start_date
      end_date = tweets.end_date
      date_range = (start_date..end_date).map {|day| day }
      emoHash = tweets.total_emotions
      csv_string = CSV.generate do |csv|
        csv << (["Date"] + emotion_category)
        date_range.each do |day|
          row = [day]
          emotion_category.each do |emotion|
            key = [day, emotion]
            row.push(emoHash[key])
          end
          csv << row
        end
      end
      csv_string
    end

    def get_daily_emotion(tweets)
      start_date = tweets.start_date
      end_date = tweets.end_date
      date_range = (start_date..end_date).map {|day| day }
    end


    def get_daily_emotion_ratio(tweets)
      start_date = tweets.start_date
      end_date = tweets.end_date
      date_range = (start_date..end_date).map {|day| day }
      total_daily_count = tweets.group("date").count(:id)
      total_daily_count.default = 0
      emotion_hash = tweets.daily_emotion_count
      emotion_hash.default = 0
      daily_emotion = []
      emotion_category = ['sadness','trust','anger','joy','disgust','fear','anticipation','surprise']
      
      emotion_category.each do |emotion|
        count_result = [emotion]
        date_range.each do |day|
          divider = total_daily_count[day]
          ratio = divider>0 ? emotion_hash[[emotion,day]]*100/divider : 0

          count_result.push ratio
        end
        daily_emotion.push count_result
      end
      date_range.insert 0, 'x'
      daily_emotion.insert 0, date_range
    end

    def get_every_emotion(tweets)
      emotion_category = ['sadness','trust','anger','joy','disgust','fear','anticipation','surprise']
      start_date = tweets.minimum(:date)
      end_date = tweets.maximum(:date)
      date_range = (start_date..end_date).map {|day| day }
      every_emotion = []
      emotion_category.each do |emotion|
        every_emotion.push get_total_emotion(tweets,date_range,emotion)
      end
      date_range.insert 0,'x'
      every_emotion.insert 0, date_range
    end


    def get_total_emotion(tweets,date_range,emotion)

      [emotion] + date_range.map{|date| tweets.where(date:date,emotion:emotion).count}
    end

    def get_emotion(tweets)
      category = ['sadness','trust','anger','joy','disgust','fear','anticipation','surprise']
  
      category.map {|emotion| [emotion,tweets.where(emotion: emotion,).count(:id)]}
     
    end

    def get_locations(tweets)
     
      tweets.select("emotion","lon","lat").map {|tweet| [tweet.emotion, tweet.lon, tweet.lat]}
      
    end

    def face_scale(emotion)
      emotion['sadness'] = emotion['sadness']*30 -20
      if emotion['sadness'] > 0
        emotion['eyebrow'] = 0
      else
        emotion['eyebrow'] = 1
        emotion['sadness'] = -emotion['sadness']
      end
      
      emotion['surprise'] = emotion['surprise'] *15 +20
      emotion['fear'] = emotion['fear'] *-10 +16
      emotion['anticipation'] = emotion['anticipation'] 
      emotion['trust'] = emotion['trust'] *0.38+0.1
      emotion['anger'] = emotion['anger'] *11+3
      emotion['joy'] = emotion['joy'] * 21 - 5
      emotion['mouth_direction'] = 0
      if emotion['joy'] < 0
        emotion['mouth_direction'] = 1
        emotion['joy'] = -emotion['joy']
      end
      emotion
    end


    def face_scale_1(emotion)
      emotion['sadness'] = emotion['sadness']* -100 + 150
      emotion['disgust'] = emotion['disgust'] *50 +15
      emotion['surprise'] = emotion['surprise'] *50 +15
      emotion['fear'] = emotion['fear'] *10 +6
      emotion['anticipation'] = emotion['anticipation'] *10 +6
      emotion['trust'] = emotion['trust'] *30 +10
      emotion['anger'] = emotion['anger'] *-100 +10
      emotion['joy'] = emotion['joy'] * 21 - 5
      emotion['mouth_direction'] = 0
      if emotion['joy'] < 0
        emotion['mouth_direction'] = 1
        emotion['joy'] = -emotion['joy']
      end
      emotion
    end

end
