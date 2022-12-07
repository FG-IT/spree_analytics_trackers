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
      if end_date > yesterday
        analytics = self.get_visits_details(tracker, tracker.analytics_id, 'day', today_s, self::SEGMENT)
        today_record = ::SpreeAnalyticsTrackers::MatomoAnalytics.new(tracker_id: tracker.id, date: today, data: JSON.generate(analytics))
      else
        today_record = nil
      end

      if start_date > yesterday
        today_record.blank? ? [] : [today_record]
      else
        records = ::SpreeAnalyticsTrackers::MatomoAnalytics.where(tracker_id: tracker.id).where("date >= ? AND date <= ?", start_date.strftime('%F'), end_date.strftime('%F'))
        records_by_date = Hash[ records.map {|r| [r.date.strftime('%F'), r] } ]

        (start_date...end_date).each do |d|
          d_s = d.strftime('%F')
          next if records_by_date.has_key?(d_s)

          analytics = self.get_visits_details(tracker, tracker.analytics_id, 'day', d_s, self::SEGMENT)

          record = ::SpreeAnalyticsTrackers::MatomoAnalytics.create(tracker_id: tracker.id, date: d_s, data: JSON.generate(analytics))
          records_by_date[d_s] = record
        end
        result = records_by_date.values.sort_by &:date
        if end_date > yesterday && today_record.present?
          result.append(today_record)
        end

        result
      end
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
        end
      end

      analytics
    end

    def self.get_visits_details(tracker, idSite = '', period = '', date = '', segment = '')
      return {} unless defined?(::Piwik)

      orders = []
      filter_limit = 100
      filter_offset = 0
      if tracker.tracker_url.start_with?('https')
        ::Piwik::PIWIK_URL ||= tracker.tracker_url
      else
        ::Piwik::PIWIK_URL ||= "https://#{tracker.tracker_url}"
      end
      ::Piwik::PIWIK_TOKEN ||= tracker.private_key

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
          visits_details = result.data.map {|item| item.deep_symbolize_keys }
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
