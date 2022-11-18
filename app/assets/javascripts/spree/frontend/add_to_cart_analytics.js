//= require spree/frontend

function gaAddToCart(variant, quantity, currency = 'USD') {
    var price = typeof variant.price === 'object' ? variant.price.amount : variant.price
    gtag(
        'event',
        'add_to_cart',
        {
            currency: currency,
            items: [{
                id: variant.id,
                name: variant.name,
                category: variant.category,
                variant: variant.options_text,
                brand: variant.brand,
                price: price,
                quantity: quantity
            }]
        }
    );
}

function segmentAddtoCart(variant, quantity, currency) {
    analytics.track('Product Added', {
        product_id: variant.id,
        sku: variant.sku,
        category: variant.category,
        name: variant.name,
        brand: variant.brand,
        price: variant.price,
        currency: currency,
        quantity: quantity
    });
}

function fpAddToCart(variant, quantity, currency = 'USD') {
    var contentIdParts = [];
    if (variant.store) {
        contentIdParts.push(variant.store);
    }
    if (variant.product_id) {
        contentIdParts.push(variant.product_id);
    }
    contentIdParts.push(variant.id);
    var contentId = contentIdParts.join('_');
    fbq('track', 'AddToCart', {
        content_type: 'product',
        content_ids: [contentId],
        content_name: variant.name,
        contents: [{id: contentId, quantity: quantity}],
        currency: currency,
        value: variant.price
    });
}

function obAddToCart(variant, quantity, currency = 'USD') {
    obApi('track', 'Add to cart');
}

Spree.ready(function () {
    $('body').on('product_add_to_cart', function (event) {
        var variant = event.variant
        var quantity = event.quantity_increment
        var currency = event.cart.currency

        if (typeof gtag !== 'undefined') {
            gaAddToCart(variant, quantity, currency)
        }

        if (typeof analytics !== 'undefined') {
            segmentAddtoCart(variant, quantity, currency)
        }

        if (typeof fbq !== 'undefined') {
            fpAddToCart(variant, quantity, currency)
        }

        if (typeof obApi !== 'undefined') {
            obAddToCart(variant, quantity, currency)
        }
    })
});
