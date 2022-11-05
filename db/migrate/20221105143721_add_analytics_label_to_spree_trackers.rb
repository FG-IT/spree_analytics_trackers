class AddAnalyticsLabelToSpreeTrackers < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_trackers, :analytics_label, :string
  end
end
