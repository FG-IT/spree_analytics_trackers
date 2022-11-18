module Spree
  module TrackersHelper
    def product_for_segment(product, optional = {})
      cache_key = [
          'spree-segment-product',
          I18n.locale,
          current_currency,
          product.cache_key_with_version
      ].compact.join('/')

      product_hash = Rails.cache.fetch(cache_key) do
        {
            product_id: begin
                          product.google_merchant_id rescue product.id
                        end,
            sku: product.sku,
            # category: product.category&.name,
            name: product.name,
            # brand: product.brand&.name,
            price: product.price_in(current_currency).amount&.to_f,
            currency: current_currency,
            url: spree.product_url(product)
        }
      end

      product_hash.tap do |hash|
        hash[:image_url] = default_image_for_product_or_variant(product)
      end.merge(optional).to_json.html_safe
    end

    def product_for_ga(product, variant)
      cache_key = [
          'spree-ga-product',
          I18n.locale,
          current_currency,
          product.cache_key_with_version
      ].compact.join('/')


      # product_hash = Rails.cache.fetch(cache_key) do
      #   {
      #       id: default_variant.id,
      #       item_id: default_variant.id,
      #       category: product.category&.name,
      #       item_name: product.name,
      #       brand: product.brand&.name,
      #       price: product.price_in(current_currency).amount&.to_f,
      #       quantity: 10,
      #       currency: current_currency
      #   }
      # end

      product_hash =
          {
              id: variant.id,
              item_id: "#{current_store.code}_#{variant.product_id}_#{variant.id}",
              # category: product.category&.name,
              item_name: product.name,
              # brand: product.brand&.name,
              price: product.price_in(current_currency).amount&.to_f,
              quantity: 10,
              currency: current_currency
          }


      product_hash.to_json.html_safe
    end


    def ga_line_item(line_item)
      variant = line_item.variant

      product = line_item.product
      {
        item_id: variant.id,
        item_name: variant.name,
        currency: line_item.currency,
        item_brand: product&.main_brand,
        # item_category: product.category&.name,
        item_variant: variant.options_text,
        quantity: line_item.quantity,
        price: line_item.price
      }.to_json.html_safe
    end

    def matomo_line_item(line_item)
      variant = line_item.variant

      cache_key = [
          'spree-matomo-line-item',
          I18n.locale,
          current_currency,
          line_item.cache_key_with_version,
          variant.cache_key_with_version
      ].compact.join('/')

      Rails.cache.fetch(cache_key) do
        product = line_item.product
        if defined?(::Spree::Representation)
          resp = product.presenter
          category = resp[:taxons].size > 0 ? resp[:taxons][-1].map {|t| t[:name] } : []
        else
          t_pathes = []
          product.taxons.each do |taxon|
            if taxon.parent_id.nil?
              next
            end

            t_path = []
            taxon.self_and_ancestors.each do |t|
              if t.name.downcase == 'categories' || t.hide_from_nav
                next
              end

              t_path << t.name
            end

            if t_path.size > 0
              t_pathes << t_path
            end
          end
          t_pathes.sort {|t1, t2| t1.size <=> t2.size }

          category = t_pathes.size > 0 ? t_pathes[-1] : []
        end

        {
          name: variant.name,
          sku: variant.sku,
          category: category,
          quantity: line_item.quantity,
          price: variant.price_in(current_currency).amount&.to_f
        }
      end
    end

    def fp_line_item(line_item)
      variant = line_item.variant
      content_id = variant.respond_to?(:feed_id) ? variant.feed_id : "#{current_store.code}_#{variant.product_id}_#{variant.id}"

      {
        id: content_id,
        name: variant.name,
        sku: variant.sku,
        quantity: line_item.quantity,
        price: variant.price_in(line_item.currency).amount&.to_f
      }
    end

    def filtering_param_present?(param)
      params.key?(param) && params.fetch(param).present?
    end

    def any_filtering_params?
      filtering_params.any? { |p| filtering_param_present?(p) }
    end

    def filtering_params_with_values
      params_with_values = {}
      filtering_params.each do |param|
        params_with_values[param] = params.fetch(param) if filtering_param_present?(param)
      end
      params_with_values
    end

    def segment_tracker
      @segment_tracker ||= Spree::Tracker.current(:segment, current_store)
    end

    def segment_enabled?
      segment_tracker.present?
    end

    def ga_tracker
      @ga_tracker ||= Spree::Tracker.current(:google_analytics, current_store)
    end

    def ga_enabled?
      ga_tracker.present?
    end

    def matomo_tracker
      @matomo_tracker ||= Spree::Tracker.current(:matomo, current_store)
    end

    def matomo_enabled?
      matomo_tracker.present?
    end

    def fp_tracker
      @fp_tracker ||= Spree::Tracker.current(:facebook_pixel, current_store)
    end

    def fp_enabled?
      fp_tracker.present?
    end

    def gads_tracker
      @gads_tracker ||= Spree::Tracker.current(:google_ads, current_store)
    end

    def gads_enabled?
      gads_tracker.present?
    end

    def em_tracker
      @em_tracker ||= Spree::Tracker.current(:em, current_store)
    end

    def em_enabled?
      em_tracker.present?
    end

    def ob_tracker
      @ob_tracker ||= Spree::Tracker.current(:outbrain, current_store)
    end

    def ob_enabled?
      ob_tracker.present?
    end

    def kv_tracker
      @kv_tracker ||= Spree::Tracker.current(:klaviyo, current_store)
    end

    def kv_enabled?
      kv_tracker.present?
    end
  end 
end
