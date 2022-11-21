//= require spree/frontend

function gaCheckout(order) {
  var event = null;
  if (order.state == 'address') {
    event = 'begin_checkout';
  } else if (order.state == 'delivery') {
    event = 'add_shipping_info';
  } else if (order.state == 'confirm' || order.state == 'complete') {
    event = 'add_payment_info'
  }
  if (!event) {
    return;
  }

  gtag('event', event, {
    send_to: 'analytics',
    value: order.total,
    currency: order.currency,
    coupon: order.coupon,
    items: order.products.map(function(product) {
      return {
        item_id: product.variant_id,
        item_name: product.name,
        currency: product.currency,
        price: product.price,
        quantity: product.quantity
      }
    })
  });
}

function fpCheckout(order) {
  var event = null;
  if (order.state == 'address') {
    event = 'InitiateCheckout';
  } else if (order.state == 'confirm' || order.state == 'complete') {
    event = 'AddPaymentInfo';
  }

  if (!event) {
    return;
  }

  fbq('track', event);
}

function segmentCheckout(order) {
  var step = '0';
  if (order.state == 'address') {
    step = '1';
  } else if (order.state == 'delivery') {
    step = '2';
  } else if (order.state == 'payment') {
    step = '3';
  } else if (order.state == 'confirm' || order.state == 'complete') {
    step = '4';
  } else {
    step = '4';
  }

  analytics.track('Checkout Step Viewed', {
    checkout_id: order.order_number,
    step: step
  });
}

Spree.ready(function () {
  $('body').on('checkout_proceed', function (event) {
    var order = event.order;

    if (typeof gtag !== 'undefined') {
      gaCheckout(order);
    }

    if (typeof analytics !== 'undefined') {
      segmentCheckout(order);
    }

    if (typeof fbq !== 'undefined') {
      fpCheckout(order);
    }
  });
});
