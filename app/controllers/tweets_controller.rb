class TweetsController < ApplicationController
  before_action :set_tweet, only: [:show, :edit, :update, :destroy]

  # GET /tweets
  # GET /tweets.json
  def index
    @tweets = Tweet.all
  end

  # GET /tweets/1
  # GET /tweets/1.json
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
    if params[:search]
      @q = Tweet.near(params[:search],20,:order => false).search(body_cont:params[:q])
    else
      @q = Tweet.search(body_cont:params[:q])
    end

    tweets = @q.result
    @show_tweets = tweets.select("emotion","body").take(5)
    gon.daily_emotion = get_daily_emotion_ratio(tweets)
    gon.total_emotion = get_emotion(tweets)
    gon.locations = get_locations(tweets)
    gon.face = tweets.emotions_ratio
    @face_feature = face_scale(tweets .emotions_ratio)
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
    # Use callbacks to share common setup or constraints between actions.
    def set_tweet
      @tweet = Tweet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tweet_params
      params.require(:tweet).permit(:body, :lon, :lat, :date, :emotion)
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
      #emotion['sadness'] = emotion['sadness']*120
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
