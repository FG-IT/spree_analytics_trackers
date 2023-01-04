module Spree
  module Admin
    class MatomoAnalyticsController < ::Spree::Admin::BaseController
      include ::Spree::TrackersHelper

      def index
      end

      def sales_performance
        start_date_s = params[:start_date]
        end_date_s = params[:end_date]

        start_date = ::Date.parse(start_date_s)
        end_date = ::Date.parse(end_date_s)
        today = ::Date.today
        end_date = today if end_date > today
        days = (end_date - start_date).to_i

        sales_data = ::SpreeAnalyticsTrackers::MatomoAnalytics.get_sales_performance(matomo_tracker, matomo_tracker.analytics_id, 'day', "#{start_date_s},#{end_date_s}")
        summary = {
          nb_conversions: 0,
          nb_visits_converted: 0,
          revenue: 0,
          conversion_rate: 0,
          nb_conversions_new_visit: 0,
          nb_visits_converted_new_visit: 0,
          revenue_new_visit: 0,
          conversion_rate_new_visit: 0,
          nb_conversions_returning_visit: 0,
          nb_visits_converted_returning_visit: 0,
          revenue_returning_visit: 0,
          conversion_rate_returning_visit: 0
        }
        sales_data.each do |sales_by_date|
          summary[:nb_conversions] += sales_by_date[:nb_conversions].to_i
          summary[:nb_visits_converted] += sales_by_date[:nb_visits_converted].to_i
          summary[:revenue] += sales_by_date[:revenue].to_f
          summary[:conversion_rate] += sales_by_date[:conversion_rate].gsub('%', '').to_f

          summary[:nb_conversions_new_visit] += sales_by_date[:nb_conversions_new_visit].to_i
          summary[:nb_visits_converted_new_visit] += sales_by_date[:nb_visits_converted_new_visit].to_i
          summary[:revenue_new_visit] += sales_by_date[:revenue_new_visit].to_f
          summary[:conversion_rate_new_visit] += sales_by_date[:conversion_rate_new_visit].gsub('%', '').to_f

          summary[:nb_conversions_returning_visit] += sales_by_date[:nb_conversions_returning_visit].to_i
          summary[:nb_visits_converted_returning_visit] += sales_by_date[:nb_visits_converted_returning_visit].to_i
          summary[:revenue_returning_visit] += sales_by_date[:revenue_returning_visit].to_f
          summary[:conversion_rate_returning_visit] += sales_by_date[:conversion_rate_returning_visit].gsub('%', '').to_f
        end
        summary[:revenue] = summary[:revenue].round(2)
        summary[:revenue_new_visit] = summary[:revenue_new_visit].round(2)
        summary[:revenue_returning_visit] = summary[:revenue_returning_visit].round(2)
        summary[:conversion_rate] = "#{(summary[:conversion_rate] / sales_data.size).round(2)}%"
        summary[:conversion_rate_new_visit] = "#{(summary[:conversion_rate_new_visit] / sales_data.size).round(2)}%"
        summary[:conversion_rate_returning_visit] = "#{(summary[:conversion_rate_returning_visit] / sales_data.size).round(2)}%"

        render json: {summary: summary, details: sales_data}
      end

      def visits_summary
        start_date_s = params[:start_date]
        end_date_s = params[:end_date]

        start_date = ::Date.parse(start_date_s)
        end_date = ::Date.parse(end_date_s)
        today = ::Date.today
        end_date = today if end_date > today
        days = (end_date - start_date).to_i

        visits_data = ::SpreeAnalyticsTrackers::MatomoAnalytics.get_visits_summary(matomo_tracker, matomo_tracker.analytics_id, 'day', "#{start_date_s},#{end_date_s}")
        summary = {
          nb_visits: 0,
          nb_actions: 0,
          nb_visits_converted: 0,
          bounce_count: 0,
          sum_visit_length: 0,
          max_actions: 0,
          bounce_rate: 0,
          nb_actions_per_visit: 0,
          avg_time_on_site: 0,
        }
        visits_data.each do |visits_by_date|
          summary[:nb_visits] += visits_by_date[:nb_visits].to_i
          summary[:nb_actions] += visits_by_date[:nb_actions].to_i
          summary[:nb_visits_converted] += visits_by_date[:nb_visits_converted].to_i
          summary[:bounce_count] += visits_by_date[:bounce_count].to_i
          summary[:sum_visit_length] += visits_by_date[:sum_visit_length].to_i
          max_actions = visits_by_date[:max_actions].to_i
          summary[:max_actions] = max_actions if summary[:max_actions] < max_actions
          summary[:nb_actions_per_visit] += visits_by_date[:nb_actions_per_visit].to_i
          summary[:avg_time_on_site] += visits_by_date[:avg_time_on_site].to_i

          visits_by_date[:bounce_rate] = visits_by_date[:bounce_rate].gsub('%', '').to_f.round(2)
        end
        summary[:bounce_rate] = (summary[:bounce_count] / summary[:nb_visits].to_f * 100).round(2)
        summary[:avg_time_on_site] = (summary[:avg_time_on_site] / visits_data.size).round

        render json: {summary: summary, details: visits_data}
      end

      def visits_by_source
        start_date_s = params[:start_date]
        end_date_s = params[:end_date]

        start_date = ::Date.parse(start_date_s)
        end_date = ::Date.parse(end_date_s)
        today = ::Date.today
        end_date = today if end_date > today
        days = (end_date - start_date).to_i

        visits_data = ::SpreeAnalyticsTrackers::MatomoAnalytics.get_visits_by_source(matomo_tracker, matomo_tracker.analytics_id, 'range', "#{start_date_s},#{end_date_s}")
        visits_data = [] if visits_data.nil?

        render json: visits_data
      end

      def visits_by_social
        start_date_s = params[:start_date]
        end_date_s = params[:end_date]

        start_date = ::Date.parse(start_date_s)
        end_date = ::Date.parse(end_date_s)
        today = ::Date.today
        end_date = today if end_date > today
        days = (end_date - start_date).to_i

        visits_data = ::SpreeAnalyticsTrackers::MatomoAnalytics.get_visits_by_social(matomo_tracker, matomo_tracker.analytics_id, 'range', "#{start_date_s},#{end_date_s}")
        visits_data = [] if visits_data.nil?

        render json: visits_data
      end

      def visits_by_device
        start_date_s = params[:start_date]
        end_date_s = params[:end_date]

        start_date = ::Date.parse(start_date_s)
        end_date = ::Date.parse(end_date_s)
        today = ::Date.today
        end_date = today if end_date > today
        days = (end_date - start_date).to_i

        visits_data = ::SpreeAnalyticsTrackers::MatomoAnalytics.get_visits_by_device(matomo_tracker, matomo_tracker.analytics_id, 'range', "#{start_date_s},#{end_date_s}")
        visits_data = [] if visits_data.nil?

        render json: visits_data
      end

      def visits_by_websites
        start_date_s = params[:start_date]
        end_date_s = params[:end_date]

        start_date = ::Date.parse(start_date_s)
        end_date = ::Date.parse(end_date_s)
        days = (end_date - start_date).to_i

        visits_data = ::SpreeAnalyticsTrackers::MatomoAnalytics.get_visits_by_websites(matomo_tracker, matomo_tracker.analytics_id, 'range', "#{start_date_s},#{end_date_s}")
        visits_data = [] if visits_data.nil?

        render json: visits_data
      end

      def visits_by_countries
        start_date_s = params[:start_date]
        end_date_s = params[:end_date]

        start_date = ::Date.parse(start_date_s)
        end_date = ::Date.parse(end_date_s)
        today = ::Date.today
        end_date = today if end_date > today
        days = (end_date - start_date).to_i

        visits_data = ::SpreeAnalyticsTrackers::MatomoAnalytics.get_visits_by_countries(matomo_tracker, matomo_tracker.analytics_id, 'range', "#{start_date_s},#{end_date_s}")
        visits_data = [] if visits_data.nil?

        render json: visits_data
      end

      def visits_by_regions
        start_date_s = params[:start_date]
        end_date_s = params[:end_date]

        start_date = ::Date.parse(start_date_s)
        end_date = ::Date.parse(end_date_s)
        today = ::Date.today
        end_date = today if end_date > today
        days = (end_date - start_date).to_i

        visits_data = ::SpreeAnalyticsTrackers::MatomoAnalytics.get_visits_by_regions(matomo_tracker, matomo_tracker.analytics_id, 'range', "#{start_date_s},#{end_date_s}")
        visits_data = [] if visits_data.nil?

        render json: visits_data
      end

      def order_analytics
        start_date_s = params[:start_date]
        end_date_s = params[:end_date]
        today = ::Date.today
        end_date = ::Date.parse(end_date_s)
        end_date = today if end_date > today
        end_date_s = end_date.strftime('%F')

        records = ::SpreeAnalyticsTrackers::MatomoAnalytics.fetch_matomo_analytics(matomo_tracker, start_date_s, end_date_s)
        analytics = ::SpreeAnalyticsTrackers::MatomoAnalytics.calc_analytics(records)

        render json: analytics
      end
    end
  end
end
