class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :body
      t.float :lon
      t.float :lat
      t.date :date
      t.string :emotion

      t.timestamps
    end
  end
end
