module SpreeAnalyticsTrackers
  class OrderPresenter < ::SpreeAnalyticsTrackers::BasePresenter
    private

    def serialize_resource(resource, options = {})
      sr = {
        order_id: resource.id,
        order_number: resource.number.to_s,
        state: resource.state,
        total: resource.total&.to_f,
        shipping: resource.shipment_total&.to_f,
        tax: resource.additional_tax_total&.to_f,
        discount: resource.promo_total&.to_f,
        coupon: resource.promo_code,
        currency: resource.currency,
        products: resource.line_items.map { |li| serialize_line_item(li) },
        email: resource.email,
      }

      address = resource&.ship_address
      if address.present?
        sr[:address] = {
          first_name: address&.firstname,
          last_name: address&.lastname,
          address1: address&.address1,
          address2: address&.address2,
          city: address&.city,
          state: address&.state_text,
          zipcode: address&.zipcode,
          country: address&.country&.iso&.to_s
        }
        sr[:phone] = address&.phone
      end

      sr
    end

    def serialize_line_item(line_item)
      {
        product_id: line_item.product_id,
        variant_id: line_item.variant_id,
        sku: line_item.sku,
        name: line_item.name,
        price: line_item.price&.to_f,
        currency: line_item.currency,
        quantity: line_item.quantity
      }
    end
  end
end