module Spree
  class Tracker < Spree::Base
    @@trackers_cache = nil

    TRACKING_ENGINES = %i(google_analytics segment matomo).freeze
    enum engine: TRACKING_ENGINES

    after_commit :clear_cache

    validates :analytics_id, presence: true, uniqueness: { scope: [:engine, :store_id], case_sensitive: false }
    validates :store, presence: true

    scope :active, -> { where(active: true) }

    belongs_to :store

    def self.current(engine = nil, store = nil)
      engine ||= TRACKING_ENGINES.first
      store  ||= Spree::Store.default

      if true
        engine = engine.to_s
        tracker = self.trackers.values.find {|t| t.active && t.store_id == store.id && t.engine == engine }
      else
        tracker = Rails.cache.fetch("current_tracker/#{engine}/#{store.id}") do
          active.find_by(store: store, engine: engine)
        end
      end
      tracker.analytics_id.present? ? tracker : nil if tracker
    end

    def self.trackers
      @@trackers_cache ||= ::Hash[ ::Spree::Tracker.all.map {|t| [t.id, t] } ]
    end

    def clear_cache
      if true
        @@trackers_cache = nil
      else
        TRACKING_ENGINES.each do |engine|
          Rails.cache.delete("current_tracker/#{engine}/#{store_id}")
        end
      end
    end
  end
end
