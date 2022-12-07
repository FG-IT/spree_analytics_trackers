class CreateSpreeMatomoAnalytics < SpreeExtension::Migration[4.2]
  def change
    unless table_exists?(:spree_matomo_analytics)
      create_table :spree_matomo_analytics do |t|
        t.integer :tracker_id, index: true
        t.date :date, index: true
        t.text :data
      end
    end
  end
end
