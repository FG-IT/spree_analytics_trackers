class AddPrivateKeyToSpreeTrackers < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_trackers, :private_key, :string
  end
end
