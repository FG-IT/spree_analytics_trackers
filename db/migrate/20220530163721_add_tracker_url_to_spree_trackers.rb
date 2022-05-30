class AddTrackerUrlToSpreeTrackers < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_trackers, :tracker_url, :string
  end
end
