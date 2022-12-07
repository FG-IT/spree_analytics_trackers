class FetchMatomoAnalyticsJob < ApplicationJob
  queue_as :default

  def perform(start_date_s, end_date_s)
    ::Spree::Tracker.where(engine: :matomo, active: true).each do |tracker|
      ::SpreeAnalyticsTrackers::MatomoAnalytics.fetch_matomo_analytics(tracker, start_date_s, end_date_s)
    end
  end

end
