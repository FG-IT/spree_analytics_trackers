module Spree
  module Admin
    class MatomoAnalyticsController < ::Spree::Admin::BaseController
      include ::Spree::TrackersHelper

      def order_analytics
        start_date_s = params[:start_date]
        end_date_s = params[:end_date]
        records = ::SpreeAnalyticsTrackers::MatomoAnalytics.fetch_matomo_analytics(matomo_tracker, start_date_s, end_date_s)
        analytics = ::SpreeAnalyticsTrackers::MatomoAnalytics.calc_analytics(records)

        render json: analytics
      end
    end
  end
end
