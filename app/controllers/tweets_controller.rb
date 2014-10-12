class TweetsController < ApplicationController
  before_action :set_tweet, only: [:show, :edit, :update, :destroy]

  # GET /tweets
  # GET /tweets.json
  def index
    @tweets = Tweet.all
  end

  # GET /tweets/1
  # GET /tweets/1.json
  def chart
    #emotions_count = get_emotion
    @every_emotion = get_every_emotion
    render plain:@every_emotion
  end

  def visualization
    @q = Tweet.search(params[:q])
    tweets = @q.result
    @show_tweets = tweets.take(5)
    gon.daily_emotion = get_every_emotion(tweets)
    gon.total_emotion = get_emotion(tweets)
    gon.locations = get_locations(tweets)
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

    def get_daily_emotion
      start_date = Tweet.minimum(:date)
      end_date = Tweet.maximum(:date)
      date_range = (start_date..end_date).map {|day| day }
      daily_emotion = []
      date_range.each do |day|
        daily_emotion.push(get_emotion(day))
      end
      daily_emotion
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
      emotion_count = [emotion]
      date_range.each do |date|
        emotion_count.push(tweets.where(date:date,emotion:emotion).count)
      end
      emotion_count

    end

    def get_emotion(tweets)
      category = ['sadness','trust','anger','joy','disgust','fear','anticipation','surprise']
      emotions_count = []
      category.each do |emotion|
        emotions_count.push [emotion, tweets.where(emotion: emotion,).count ]
      end
      emotions_count
    end

    def get_locations(tweets)
      tweets_locations = []
      tweets.each do |tweet|
        tweets_locations.push [tweet.emotion,tweet.lon,tweet.lat]
      end
      tweets_locations
    end

end
