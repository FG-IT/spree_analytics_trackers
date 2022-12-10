require 'piwik'

module SpreeAnalyticsTrackers
  class MatomoAnalytics < ::Spree::Base
    self.table_name = "spree_matomo_analytics"

    SEGMENT = 'visitEcommerceStatus==ordered,visitEcommerceStatus==orderedThenAbandonedCart,visitEcommerceStatus==abandonedCart'

    def self.fetch_matomo_analytics(tracker, start_date_s, end_date_s)
      today = ::Date.today
      today_s = today.strftime('%F')
      yesterday = ::Date.yesterday
      start_date = ::Date.parse(start_date_s)
      end_date = ::Date.parse(end_date_s)
      # if end_date > yesterday
      #   analytics = self.get_visits_details(tracker, tracker.analytics_id, 'day', today_s, self::SEGMENT)
      #   today_record = ::SpreeAnalyticsTrackers::MatomoAnalytics.new(tracker_id: tracker.id, date: today, data: JSON.generate(analytics))
      # else
      #   today_record = nil
      # end
      # if start_date > yesterday
      #   today_record.blank? ? [] : [today_record]
      # else
      #   records = ::SpreeAnalyticsTrackers::MatomoAnalytics.where(tracker_id: tracker.id).where("date >= ? AND date <= ?", start_date.strftime('%F'), end_date.strftime('%F'))
      #   records_by_date = Hash[ records.map {|r| [r.date.strftime('%F'), r] } ]

      #   (start_date...end_date).each do |d|
      #     d_s = d.strftime('%F')
      #     next if records_by_date.has_key?(d_s)

      #     analytics = self.get_visits_details(tracker, tracker.analytics_id, 'day', d_s, self::SEGMENT)

      #     record = ::SpreeAnalyticsTrackers::MatomoAnalytics.create(tracker_id: tracker.id, date: d_s, data: JSON.generate(analytics))
      #     records_by_date[d_s] = record
      #   end
      #   result = records_by_date.values.sort_by &:date
      #   if end_date > yesterday && today_record.present?
      #     result.append(today_record)
      #   end

      #   result
      # end

      start_date = yesterday if start_date > yesterday
      end_date = yesterday if end_date > yesterday

      records = ::SpreeAnalyticsTrackers::MatomoAnalytics.where(tracker_id: tracker.id).where("date >= ? AND date <= ?", start_date.strftime('%F'), end_date.strftime('%F'))
      records_by_date = Hash[ records.map {|r| [r.date.strftime('%F'), r] } ]

      (start_date..end_date).each do |d|
        d_s = d.strftime('%F')
        next if records_by_date.has_key?(d_s)

        analytics = self.get_visits_details(tracker, tracker.analytics_id, 'day', d_s, self::SEGMENT)

        record = ::SpreeAnalyticsTrackers::MatomoAnalytics.create(tracker_id: tracker.id, date: d_s, data: JSON.generate(analytics))
        records_by_date[d_s] = record
      end
      records_by_date.values.sort_by &:date
    end

    def self.calc_analytics(matomo_analytics)
      analytics = {ordered: {}, abandonedCart: {}, devices: {ordered: {}, abandonedCart: {}}, visitor_types: {ordered: {}, abandonedCart: {}}}
      matomo_analytics.each do |record|
        data = JSON.parse(record.data, {symbolize_names: true})
        [:ordered, :abandonedCart].each do |s|
          data[s].each do |k, v|
            if analytics[s].has_key?(k)
              v.each do |ik, iv|
                if analytics[s][k].has_key?(ik)
                  analytics[s][k][ik] += iv
                else
                  analytics[s][k][ik] = iv
                end
              end
            else
              analytics[s][k] = v.clone
            end
          end
          analytics[s].each do |k, item|
            analytics[s][k][:sales] = item[:sales].round(2)
          end

          data[:devices][s].each do |k, v|
            if analytics[:devices][s].has_key?(k)
              v.each do |ik, iv|
                if analytics[:devices][s][k].has_key?(ik)
                  analytics[:devices][s][k][ik] += iv
                else
                  analytics[:devices][s][k][ik] = iv
                end
              end
            else
              analytics[:devices][s][k] = v.clone
            end
          end
          analytics[:devices][s].each {|k, item| analytics[:devices][s][k][:sales] = item[:sales].round(2) }

          data[:visitor_types][s].each do |k, v|
            if analytics[:visitor_types][s].has_key?(k)
              v.each do |ik, iv|
                if analytics[:visitor_types][s][k].has_key?(ik)
                  analytics[:visitor_types][s][k][ik] += iv
                else
                  analytics[:visitor_types][s][k][ik] = iv
                end
              end
            else
              analytics[:visitor_types][s][k] = v.clone
            end
          end
          analytics[:visitor_types][s].each {|k, item| analytics[:visitor_types][s][k][:sales] = item[:sales].round(2) }
        end
      end

      analytics
    end

    def self.init_tracker(tracker)
      if tracker.tracker_url.start_with?('https')
        ::Piwik::PIWIK_URL ||= tracker.tracker_url
      else
        ::Piwik::PIWIK_URL ||= "https://#{tracker.tracker_url}"
      end
      ::Piwik::PIWIK_TOKEN ||= tracker.private_key
    end

    def self.get_sales_performance(tracker, idSite = '', period = '', date = '', segment = '')
      # Sample data when period is day. {"result"=>[{"date"=>"2022-12-02", "nb_conversions"=>"13", "nb_visits_converted"=>"14", "revenue"=>"477.79", "conversion_rate"=>"1.13%", "nb_conversions_new_visit"=>"10", "nb_visits_converted_new_visit"=>"10", "revenue_new_visit"=>"381.28", "conversion_rate_new_visit"=>"0.93%", "nb_conversions_returning_visit"=>"3", "nb_visits_converted_returning_visit"=>"4", "revenue_returning_visit"=>"96.51", "conversion_rate_returning_visit"=>"2.35%"}]}
      # Sample data when period is range. {"nb_conversions"=>"120", "nb_visits_converted"=>"125", "revenue"=>"5990.79", "conversion_rate"=>"0.78%", "nb_conversions_new_visit"=>"105", "nb_visits_converted_new_visit"=>"104", "revenue_new_visit"=>"4892.53", "conversion_rate_new_visit"=>"0.77%", "nb_conversions_returning_visit"=>"15", "nb_visits_converted_returning_visit"=>"21", "revenue_returning_visit"=>"1098.26", "conversion_rate_returning_visit"=>"0.86%"}

      self.init_tracker(tracker)
      begin
        resp = ::Piwik::Goals.get(idSite: idSite, period: period, date: date, segment: segment)
        result = resp.data.deep_symbolize_keys
        if period == 'range'
          result
        else
          result.has_key?(:result) ? (result[:result].is_a?(Array) ? result[:result] : [result[:result]]) : [result]
        end
      rescue ::Piwik::ApiError, ::ArgumentError => e
        Rails.logger.debug(e.message)
        Rails.logger.debug(e.backtrace.join("\n"))
      end
    end

    def self.get_visits_summary(tracker, idSite = '', period = '', date = '', segment = '')
      # Sample data when period is day. {"result"=>[{"date"=>"2022-12-03", "nb_uniq_visitors"=>"2402", "nb_users"=>"4", "nb_visits"=>"2759", "nb_actions"=>"3751", "nb_visits_converted"=>"25", "bounce_count"=>"2330", "sum_visit_length"=>"95562", "max_actions"=>"28", "bounce_rate"=>"84%", "nb_actions_per_visit"=>"1.4", "avg_time_on_site"=>"35"}]}
      # Sample data when period is range. {"nb_visits"=>"18004", "nb_actions"=>"25224", "nb_visits_converted"=>"142", "bounce_count"=>"15311", "sum_visit_length"=>"718597", "max_actions"=>"77", "bounce_rate"=>"85%", "nb_actions_per_visit"=>"1.4", "avg_time_on_site"=>"40"}

      self.init_tracker(tracker)
      begin
        resp = ::Piwik::VisitsSummary.get(idSite: idSite, period: period, date: date, segment: segment, filter_sort_column: 'nb_conversions', filter_sort_order:
 'desc')
        result = resp.data.deep_symbolize_keys
        if period == 'range'
          result
        else
          result.has_key?(:result) ? (result[:result].is_a?(Array) ? result[:result] : [result[:result]]) : [result]
        end
      rescue ::Piwik::ApiError, ::ArgumentError => e
        Rails.logger.debug(e.message)
        Rails.logger.debug(e.backtrace.join("\n"))
      end
    end

    def self.get_visits_by_source(tracker, idSite = '', period = '', date = '', segment = '')
      # Sample data when period is day. {"result"=>[{"date"=>"2022-12-02", "row"=>[{"label"=>"Campaigns", "nb_uniq_visitors"=>"729", "nb_visits"=>"796", "nb_actions"=>"982", "nb_users"=>"0", "max_actions"=>"15", "sum_visit_length"=>"34132", "bounce_count"=>"704", "nb_visits_converted"=>"4", "goals"=>{"row"=>[{"idgoal"=>"ecommerceAbandonedCart", "nb_conversions"=>"5", "nb_visits_converted"=>"5", "revenue"=>"302.47", "items"=>"7"}, {"idgoal"=>"ecommerceOrder", "nb_conversions"=>"4", "nb_visits_converted"=>"4", "revenue"=>"209.7", "revenue_subtotal"=>"209.7", "revenue_tax"=>"9.74", "revenue_shipping"=>"0", "revenue_discount"=>"0", "items"=>"4"}]}, "nb_conversions"=>"4", "revenue"=>"209.7", "segment"=>"referrerType==campaign", "referrer_type"=>"6", "idsubdatatable"=>"6"}]}]}
      # Sample data when period is range. [{"label"=>"Campaigns", "nb_visits"=>"10909", "nb_actions"=>"12966", "max_actions"=>"45", "sum_visit_length"=>"277196", "bounce_count"=>"9701", "nb_visits_converted"=>"33", "goals"=>{"row"=>[{"idgoal"=>"ecommerceAbandonedCart", "nb_conversions"=>"112", "nb_visits_converted"=>"112", "revenue"=>"3679.32", "items"=>"120"}, {"idgoal"=>"ecommerceOrder", "nb_conversions"=>"33", "nb_visits_converted"=>"33", "revenue"=>"1464.68", "revenue_subtotal"=>"1464.68", "revenue_tax"=>"78.04", "revenue_shipping"=>"0", "revenue_discount"=>"-15", "items"=>"40"}]}, "nb_conversions"=>"33", "revenue"=>"1464.68", "sum_daily_nb_uniq_visitors"=>"10126", "sum_daily_nb_users"=>"3", "segment"=>"referrerType==campaign", "referrer_type"=>"6", "idsubdatatable"=>"6"}]

      self.init_tracker(tracker)
      begin
        resp = ::Piwik::Referrers.getReferrerType(idSite: idSite, period: period, date: date, segment: segment, filter_sort_column: 'nb_conversions', filter_sort_order:
 'desc')
        result = resp.data
        if period == 'range'
          result.map {|r| r.deep_symbolize_keys }
        else
          result = result.deep_symbolize_keys
          result.has_key?(:result) ? (result[:result].is_a?(Array) ? result[:result] : [result[:result]]) : [result]
        end
      rescue ::Piwik::ApiError, ::ArgumentError => e
        Rails.logger.debug(e.message)
        Rails.logger.debug(e.backtrace.join("\n"))
      end
    end

    def self.get_visits_by_social(tracker, idSite = '', period = '', date = '', segment = '')
      # Sample data when period is day. {"result"=>[{"date"=>"2022-12-02", "row"=>[{"label"=>"Facebook", "nb_uniq_visitors"=>"8", "nb_visits"=>"8", "nb_actions"=>"9", "nb_users"=>"0", "max_actions"=>"2", "sum_visit_length"=>"794", "bounce_count"=>"7", "nb_visits_converted"=>"0", "url"=>"facebook.com", "logo"=>"plugins/Morpheus/icons/dist/socials/facebook.com.png", "idsubdatatable"=>"1"}, {"label"=>"Pinterest", "nb_uniq_visitors"=>"5", "nb_visits"=>"5", "nb_actions"=>"7", "nb_users"=>"0", "max_actions"=>"3", "sum_visit_length"=>"98", "bounce_count"=>"4", "nb_visits_converted"=>"0", "url"=>"pinterest.com", "logo"=>"plugins/Morpheus/icons/dist/socials/pinterest.com.png", "idsubdatatable"=>"3"}]}]}
      # Sample data when period is range. [{"label"=>"Facebook", "nb_visits"=>"103", "nb_actions"=>"276", "max_actions"=>"37", "sum_visit_length"=>"18244", "bounce_count"=>"73", "nb_visits_converted"=>"8", "sum_daily_nb_uniq_visitors"=>"100", "sum_daily_nb_users"=>"3", "goals"=>{"row"=>[{"idgoal"=>"ecommerceAbandonedCart", "nb_conversions"=>"8", "nb_visits_converted"=>"8", "revenue"=>"330.27", "items"=>"10"}, {"idgoal"=>"ecommerceOrder", "nb_conversions"=>"8", "nb_visits_converted"=>"8", "revenue"=>"229.4", "revenue_subtotal"=>"229.4", "revenue_tax"=>"11.93", "revenue_shipping"=>"0", "revenue_discount"=>"0", "items"=>"8"}]}, "nb_conversions"=>"8", "revenue"=>"229.4", "url"=>"facebook.com", "logo"=>"plugins/Morpheus/icons/dist/socials/facebook.com.png", "idsubdatatable"=>"1"}]

      self.init_tracker(tracker)
      begin
        resp = ::Piwik::Referrers.getSocials(idSite: idSite, period: period, date: date, segment: segment, filter_sort_column: 'nb_conversions', filter_sort_order:
 'desc')
        result = resp.data
        if period == 'range'
          result.map {|r| r.deep_symbolize_keys }
        else
          result = result.deep_symbolize_keys
          result.has_key?(:result) ? (result[:result].is_a?(Array) ? result[:result] : [result[:result]]) : [result]
        end
      rescue ::Piwik::ApiError, ::ArgumentError => e
        Rails.logger.debug(e.message)
        Rails.logger.debug(e.backtrace.join("\n"))
      end
    end

    def self.get_visits_by_device(tracker, idSite = '', period = '', date = '', segment = '')
      # Sample data when period is day. {"result"=>[{"date"=>"2022-12-02", "row"=>[{"label"=>"Smartphone", "nb_uniq_visitors"=>"856", "nb_visits"=>"984", "nb_actions"=>"1278", "nb_users"=>"0", "max_actions"=>"15", "sum_visit_length"=>"42086", "bounce_count"=>"855", "nb_visits_converted"=>"10", "goals"=>{"row"=>[{"idgoal"=>"ecommerceAbandonedCart", "nb_conversions"=>"7", "nb_visits_converted"=>"7", "revenue"=>"324.8", "items"=>"6"}, {"idgoal"=>"ecommerceOrder", "nb_conversions"=>"9", "nb_visits_converted"=>"9", "revenue"=>"294.61", "revenue_subtotal"=>"294.61", "revenue_tax"=>"13.77", "revenue_shipping"=>"0", "revenue_discount"=>"0", "items"=>"9"}]}, "nb_conversions"=>"9", "revenue"=>"294.61", "segment"=>"deviceType==smartphone", "logo"=>"plugins/Morpheus/icons/dist/devices/smartphone.png"}]}]}
      # Sample data when period is range. [{"label"=>"Smartphone", "nb_visits"=>"13573", "nb_actions"=>"17749", "max_actions"=>"77", "sum_visit_length"=>"434696", "bounce_count"=>"11673", "nb_visits_converted"=>"80", "goals"=>{"row"=>[{"idgoal"=>"ecommerceAbandonedCart", "nb_conversions"=>"203", "nb_visits_converted"=>"203", "revenue"=>"14428.82", "items"=>"249"}, {"idgoal"=>"ecommerceOrder", "nb_conversions"=>"75", "nb_visits_converted"=>"75", "revenue"=>"3796.22", "revenue_subtotal"=>"3730.58", "revenue_tax"=>"208.41", "revenue_shipping"=>"44.95", "revenue_discount"=>"-22.24", "items"=>"100"}]}, "nb_conversions"=>"75", "revenue"=>"3796.22", "sum_daily_nb_uniq_visitors"=>"11934", "sum_daily_nb_users"=>"3", "segment"=>"deviceType==smartphone", "logo"=>"plugins/Morpheus/icons/dist/devices/smartphone.png"}]

      self.init_tracker(tracker)
      begin
        resp = ::Piwik::DevicesDetection.getType(idSite: idSite, period: period, date: date, segment: segment, filter_sort_column: 'nb_conversions', filter_sort_order:
 'desc')
        result = resp.data
        if period == 'range'
          result.map {|r| r.deep_symbolize_keys }
        else
          result = result.deep_symbolize_keys
          result.has_key?(:result) ? (result[:result].is_a?(Array) ? result[:result] : [result[:result]]) : [result]
        end
      rescue ::Piwik::ApiError, ::ArgumentError => e
        Rails.logger.debug(e.message)
        Rails.logger.debug(e.backtrace.join("\n"))
      end
    end

    def self.get_visits_by_websites(tracker, idSite = '', period = '', date = '', segment = '')
      # Sample data when period is day. {"result"=>[{"date"=>"2022-12-02", "row"=>[{"label"=>"com.pinterest", "nb_uniq_visitors"=>"3", "nb_visits"=>"3", "nb_actions"=>"3", "nb_users"=>"0", "max_actions"=>"1", "sum_visit_length"=>"0", "bounce_count"=>"3", "nb_visits_converted"=>"0", "segment"=>"referrerName==com.pinterest", "idsubdatatable"=>"2"}, {"label"=>"members.cj.com", "nb_uniq_visitors"=>"2", "nb_visits"=>"2", "nb_actions"=>"14", "nb_users"=>"0", "max_actions"=>"12", "sum_visit_length"=>"392", "bounce_count"=>"0", "nb_visits_converted"=>"0", "segment"=>"referrerName==members.cj.com", "idsubdatatable"=>"6"}]}]}
      # Sample data when period is range. [{"label"=>"com.pinterest", "nb_visits"=>"39", "nb_actions"=>"41", "max_actions"=>"2", "sum_visit_length"=>"125", "bounce_count"=>"37", "nb_visits_converted"=>"0", "sum_daily_nb_uniq_visitors"=>"37", "sum_daily_nb_users"=>"0", "segment"=>"referrerName==com.pinterest", "idsubdatatable"=>"2"}]

      self.init_tracker(tracker)
      begin
        resp = ::Piwik::DevicesDetection.getType(idSite: idSite, period: period, date: date, segment: segment, filter_sort_column: 'nb_conversions', filter_sort_order:
 'desc')
        result = resp.data
        if period == 'range'
          result.map {|r| r.deep_symbolize_keys }
        else
          result = result.deep_symbolize_keys
          result.has_key?(:result) ? (result[:result].is_a?(Array) ? result[:result] : [result[:result]]) : [result]
        end
      rescue ::Piwik::ApiError, ::ArgumentError => e
        Rails.logger.debug(e.message)
        Rails.logger.debug(e.backtrace.join("\n"))
      end
    end

    def self.get_visits_by_countries(tracker, idSite = '', period = '', date = '', segment = '')
      # Sample data when period is day. {"result"=>[{"date"=>"2022-12-04", "row"=>[{"label"=>"United States", "nb_uniq_visitors"=>"2838", "nb_visits"=>"3176", "nb_actions"=>"4265", "nb_users"=>"0", "max_actions"=>"67", "sum_visit_length"=>"120540", "bounce_count"=>"2699", "nb_visits_converted"=>"27", "goals"=>{"row"=>[{"idgoal"=>"ecommerceAbandonedCart", "nb_conversions"=>"54", "nb_visits_converted"=>"54", "revenue"=>"4157.24", "items"=>"67"}, {"idgoal"=>"ecommerceOrder", "nb_conversions"=>"26", "nb_visits_converted"=>"26", "revenue"=>"1318.35", "revenue_subtotal"=>"1293.38", "revenue_tax"=>"69.14", "revenue_shipping"=>"24.97", "revenue_discount"=>"-3.24", "items"=>"32"}]}, "nb_conversions"=>"26", "revenue"=>"1318.35", "code"=>"us", "logo"=>"plugins/Morpheus/icons/dist/flags/us.png", "segment"=>"countryCode==us", "logoHeight"=>"16"}]}]}
      # Sample data when period is range. [{"label"=>"United States", "nb_visits"=>"17258", "nb_actions"=>"24040", "max_actions"=>"83", "sum_visit_length"=>"665319", "bounce_count"=>"14658", "nb_visits_converted"=>"147", "goals"=>{"row"=>[{"idgoal"=>"ecommerceAbandonedCart", "nb_conversions"=>"342", "nb_visits_converted"=>"342", "revenue"=>"25461.97", "items"=>"433"}, {"idgoal"=>"ecommerceOrder", "nb_conversions"=>"146", "nb_visits_converted"=>"141", "revenue"=>"7388.93", "revenue_subtotal"=>"7293.65", "revenue_tax"=>"413.99", "revenue_shipping"=>"59.93", "revenue_discount"=>"-45.14", "items"=>"194"}]}, "nb_conversions"=>"146", "revenue"=>"7388.93", "sum_daily_nb_uniq_visitors"=>"15473", "sum_daily_nb_users"=>"41", "code"=>"us", "logo"=>"plugins/Morpheus/icons/dist/flags/us.png", "segment"=>"countryCode==us", "logoHeight"=>"16"}]

      self.init_tracker(tracker)
      begin
        resp = ::Piwik::UserCountry.getCountry(idSite: idSite, period: period, date: date, segment: segment, filter_sort_column: 'nb_conversions', filter_sort_order:
 'desc', filter_limit: 10)
        result = resp.data
        if period == 'range'
          result.map {|r| r.deep_symbolize_keys }
        else
          result = result.deep_symbolize_keys
          result.has_key?(:result) ? (result[:result].is_a?(Array) ? result[:result] : [result[:result]]) : [result]
        end
      rescue ::Piwik::ApiError, ::ArgumentError => e
        Rails.logger.debug(e.message)
        Rails.logger.debug(e.backtrace.join("\n"))
      end
    end

    def self.get_visits_by_regions(tracker, idSite = '', period = '', date = '', segment = '')
      # Sample data when period is day. {"result"=>[{"date"=>"2022-12-04", "row"=>[{"label"=>"California, United States", "nb_uniq_visitors"=>"351", "nb_visits"=>"389", "nb_actions"=>"607", "nb_users"=>"0", "max_actions"=>"31", "sum_visit_length"=>"16033", "bounce_count"=>"325", "nb_visits_converted"=>"7", "goals"=>{"row"=>[{"idgoal"=>"ecommerceAbandonedCart", "nb_conversions"=>"9", "nb_visits_converted"=>"9", "revenue"=>"650.66", "items"=>"8"}, {"idgoal"=>"ecommerceOrder", "nb_conversions"=>"7", "nb_visits_converted"=>"7", "revenue"=>"462.97", "revenue_subtotal"=>"452.98", "revenue_tax"=>"31.5", "revenue_shipping"=>"9.99", "revenue_discount"=>"-3.24", "items"=>"10"}]}, "nb_conversions"=>"7", "revenue"=>"462.97", "segment"=>"regionCode==CA;countryCode==us", "region"=>"CA", "country"=>"us", "country_name"=>"United States", "region_name"=>"California", "logo"=>"plugins/Morpheus/icons/dist/flags/us.png"}]}]}
      # Sample data when period is range. [{"label"=>"California, United States", "nb_visits"=>"2209", "nb_actions"=>"3127", "max_actions"=>"31", "sum_visit_length"=>"77845", "bounce_count"=>"1873", "nb_visits_converted"=>"25", "goals"=>{"row"=>[{"idgoal"=>"ecommerceAbandonedCart", "nb_conversions"=>"49", "nb_visits_converted"=>"49", "revenue"=>"3756.65", "items"=>"50"}, {"idgoal"=>"ecommerceOrder", "nb_conversions"=>"24", "nb_visits_converted"=>"24", "revenue"=>"1911.48", "revenue_subtotal"=>"1901.49", "revenue_tax"=>"131.23", "revenue_shipping"=>"9.99", "revenue_discount"=>"-30.09", "items"=>"39"}]}, "nb_conversions"=>"24", "revenue"=>"1911.48", "sum_daily_nb_uniq_visitors"=>"1992", "sum_daily_nb_users"=>"3", "segment"=>"regionCode==CA;countryCode==us", "region"=>"CA", "country"=>"us", "country_name"=>"United States", "region_name"=>"California", "logo"=>"plugins/Morpheus/icons/dist/flags/us.png"}]

      self.init_tracker(tracker)
      begin
        resp = ::Piwik::UserCountry.getRegion(idSite: idSite, period: period, date: date, segment: segment, filter_sort_column: 'nb_conversions', filter_sort_order:
 'desc', filter_limit: 10)
        result = resp.data
        if period == 'range'
          result.map {|r| r.deep_symbolize_keys }
        else
          result = result.deep_symbolize_keys
          result.has_key?(:result) ? (result[:result].is_a?(Array) ? result[:result] : [result[:result]]) : [result]
        end
      rescue ::Piwik::ApiError, ::ArgumentError => e
        Rails.logger.debug(e.message)
        Rails.logger.debug(e.backtrace.join("\n"))
      end
    end

    def self.get_visits_details(tracker, idSite = '', period = '', date = '', segment = '')
      return {} unless defined?(::Piwik)

      orders = []
      filter_limit = 100
      filter_offset = 0
      self.init_tracker(tracker)

      d = ::Date.parse(date)

      while true do
        params = {
          idSite: idSite,
          period: period,
          date: date,
          segment: segment,
          # countVisitorsToFetch: countVisitorsToFetch,
          # minTimestamp: minTimestamp,
          # flat: flat,
          # doNotFetchActions: doNotFetchActions,
          # enhanced: enhanced
        }
        if filter_offset > 0
          params[:filter_offset] = filter_offset
        end

        begin
          result  = ::Piwik::Live.getLastVisitsDetails(**params)
          if result.data.is_a?(::Hash)
            visits_details = [result.data.deep_symbolize_keys]
          elsif result.data.is_a?(::Array)
            visits_details = result.data.map {|item| item.deep_symbolize_keys }
          else
            visits_details = []
          end
        rescue ::Piwik::ApiError, ::ArgumentError => e
          Rails.logger.debug(e.message)
          Rails.logger.debug(e.backtrace.join("\n"))
          visits_details = []
        end

        begin
          orders.concat(self.classify_orders_by_source(visits_details))
        rescue => e
          Rails.logger.debug(e.message)
          Rails.logger.debug(e.backtrace.join("\n"))
        end

        break if visits_details.size < filter_limit

        filter_offset += filter_limit
      end

      result = {ordered: {}, abandonedCart: {}, devices: {ordered: {}, abandonedCart: {}}, visitor_types: {ordered: {}, abandonedCart: {}}}
      begin
        orders.each do |order|
          type = order[:type]
          source = order[:source]
          unless result[type].has_key?(source)
            result[type][source] = {orders: 0, sales: 0}
          end
          result[type][source][:orders] += order[:orders]
          result[type][source][:sales] += order[:sales]

          device_type = order[:device_type]
          unless result[:devices][type].has_key?(device_type)
            result[:devices][type][device_type] = {orders: 0, sales: 0}
          end
          result[:devices][type][device_type][:orders] += order[:orders]
          result[:devices][type][device_type][:sales] += order[:sales]

          visitor_type = order[:visitor_type]
          unless result[:visitor_types][type].has_key?(visitor_type)
            result[:visitor_types][type][visitor_type] = {orders: 0, sales: 0}
          end
          result[:visitor_types][type][visitor_type][:orders] += order[:orders]
          result[:visitor_types][type][visitor_type][:sales] += order[:sales]
        end
      rescue => e
        Rails.logger.debug(e.message)
        Rails.logger.debug(e.backtrace.join("\n"))
      end

      result
    end

    def self.classify_orders_by_source(visits_details)
      orders = []

      return orders if visits_details.blank?

      visits_details.each do |visit_details|
        if visit_details[:visitEcommerceStatus].include?('ordered')
          type = :ordered
          conversions = visit_details[:totalEcommerceConversions].to_i
          revenue = visit_details[:totalEcommerceRevenue].to_f
        else
          type = :abandonedCart
          conversions = visit_details[:totalAbandonedCarts].to_i
          revenue = visit_details[:totalAbandonedCartsRevenue].to_i
        end
        visitor_type = visit_details[:visitorType]
        device_type = visit_details[:deviceType]
        base = {type: type, orders: conversions, sales: revenue, visitor_type: visitor_type, device_type: device_type}

        source = nil

        Rails.logger.debug("[Campaign] ID: #{visit_details[:campaignId]}, Source: #{visit_details[:campaignSource]}, Medium: #{visit_details[:campaignMedium]}, Name: #{visit_details[:campaignName]}")

        campaign_source = visit_details[:campaignSource]&.downcase || '' if visit_details[:campaignSource].present?
        if campaign_source == 'google'
          source = 'Google Ads'
        elsif campaign_source == 'facebook'
          source = 'Facebook Ads'
        elsif campaign_source == 'outbrain'
          source = 'Outbrain'
        elsif campaign_source == 'klaviyo'
          source = 'Klaviyo'
        elsif campaign_source.present?
          source = campaign_source
        end
        if source.present?
          base[:source] = source
          orders << base

          next
        end

        Rails.logger.debug("[AdProvider] ClickId: #{visit_details[:adClickId]}, ProviderId: #{visit_details[:adProviderId]}, ProviderName: #{visit_details[:adProviderName]}")

        provider_id = visit_details[:adProviderId]&.downcase || '' if visit_details[:adProviderId].present?
        if provider_id == 'google'
          source = 'Google Ads'
        elsif provider_id == 'facebook'
          source = 'Facebook Ads'
        elsif provider_id.present?
          source = provider_id
        end
        if source.present?
          base[:source] = source
          orders << base

          next
        end

        action_detail = visit_details[:actionDetails].fetch(:row, {})
        action_detail = action_detail.first if action_detail.is_a?(Array)
        Rails.logger.debug("[URL] #{action_detail&.fetch(:url, '')}")

        landing_url = action_detail.fetch(:url, '') || '' if action_detail.present?
        landing_url = '' if landing_url.is_a?(Hash)
        if landing_url.match?(/srsltid=.*/)
          source = 'Google Free Traffic'
        elsif landing_url.match?(/(gclid=|wbraid=|gbraid=)/)
          source = 'Google Ads'
        elsif landing_url.match?(/fbclid=.*/)
          source = 'Facebook Ads'
        elsif landing_url.match?(/_kx=.*/)
          source = 'Klaviyo'
        elsif landing_url.match?(/sscid=.*/)
          source = 'ShareASale'
        elsif landing_url.match?(/cjevent=.*/)
          source = 'CJ Affiliate'
        end
        if source.present?
          base[:source] = source
          orders << base

          next
        end

        Rails.logger.debug("[Refer] Type: #{visit_details[:referrerType]}, TypeName: #{visit_details[:referrerTypeName]}, Name: #{visit_details[:referrerName]}, URL: #{visit_details[:referrerUrl]}")

        referrer_type = visit_details[:referrerType] || '' if visit_details[:referrerType].present?
        referrer_url = visit_details[:referrerUrl] || '' if visit_details[:referrerUrl].present?
        begin
          if referrer_url.present?
            uri = URI.parse(referrer_url)
            host_parts = uri.host.split('.')
            if host_parts.size > 2
              host_parts.shift
            end
            referrer_top_domain = host_parts.join('.')
            if referrer_top_domain.present?
              source = referrer_top_domain
            end
          else
            source = 'Other'
          end
        rescue => e
          Rails.logger.warning("[ReferrerError] Type: #{visit_details[:referrerType]}, TypeName: #{visit_details[:referrerTypeName]}, Name: #{visit_details[:referrerName]}, URL: #{visit_details[:referrerUrl]}")
          source = 'Other'
        end
        base[:source] = source
        orders << base

      end

      orders
    end
  end
end
