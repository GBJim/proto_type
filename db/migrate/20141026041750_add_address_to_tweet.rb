class AddAddressToTweet < ActiveRecord::Migration
  def change
    add_column :tweets, :address, :string
  end
end
