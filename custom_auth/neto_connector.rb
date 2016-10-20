{
  title: 'Neto',

  connection: {
    fields: [
      {
      	name: 'domain',
        control_type: 'subdomain',
        url: '.neto.com.au',
        optional: false
      },
      {
        name: 'api_key',
        control_type: 'password', optional: false
      }
    ],

    authorization: {
      type: 'custom_auth',

      credentials: ->(connection) {
        headers('NETOAPI_KEY': connection['api_key'])
      }
    }
  },

  object_definitions: {

    customer: {

      fields: ->() {
        [
          { name: 'ID' },
          { name: 'EmailAddress', control_type: 'email' },
          { name: 'Username' },
          { name: 'DateUpdated', type: :date_time },
          { name: 'DateAdded', type: :date_time }
        ]
      }
    },

    order: {

      fields: ->() {
        [
          { name: "OrderID" },
          { name: "ShippingOption" },
          { name: "DeliveryInstruction" },
          { name: "Username" },
          { name: "Email", control_type: 'email' },
          { name: "ShipAddress" },
          { name: "BillAddress" },
          { name: "PurchaseOrderNumber" },
          { name: "CustomerRef1" },
          { name: "CustomerRef2" },
          { name: "CustomerRef3" },
          { name: "CustomerRef4" },
          { name: "SalesChannel" },
          { name: "GrandTotal" },
          { name: "TaxInclusive" },
          { name: "OrderTax" },
          { name: "SurchargeTotal" },
          { name: "SurchargeTaxable" },
          { name: "ProductSubtotal" },
          { name: "ShippingTotal" },
          { name: "ShippingTax" },
          { name: "ClientIPAddress" },
          { name: "CouponCode" },
          { name: "CouponDiscount" },
          { name: "ShippingDiscount" },
          { name: "OrderType" },
          { name: "OrderStatus" },
          { name: "OrderPayment", type: :array, of: :object, parse_output: :item_array_wrap, properties: [
            { name: "OrderPaymentId" },﻿
            { name: "OrderPaymentAmount" },﻿
            { name: "PaymentType" }
          ]},
          { name: "DateUpdated", type: :date_time },
          { name: "DatePlaced", type: :date_time },
          { name: "DateRequired", type: :date_time },
          { name: "DateInvoiced", type: :date_time },
          { name: "DatePaid", type: :date_time },
          { name: "DateCompleted", type: :date_time },
          { name: "OrderLine", type: :array, of: :object, parse_output: :item_array_wrap, properties: [
            { name: "ProductName" },
            { name: "ItemNotes" },
            { name: "PickQuantity" },
            { name: "BackorderQuantity" },
            { name: "UnitPrice" },
            { name: "Tax" },
            { name: "TaxCode" },
            { name: "WarehouseID", type: :integer },
            { name: "WarehouseName" },
            { name: "WarehouseReference" },
            { name: "Quantity", type: :integer },
            { name: "PercentDiscount" },
            { name: "ProductDiscount" },
            { name: "CouponDiscount" },
            { name: "CostPrice" },
            { name: "ShippingMethod" },
            { name: "ShippingTracking" },
            { name: "Weight" },
            { name: "Cubic" },
            { name: "Extra" },
            { name: "eBay", type: :object, properties: [
              { name: "eBayUsername" },
              { name: "eBayStoreName" },
              { name: "eBayTransactionID" },
              { name: "eBayAuctionID" },
              { name: "ListingType" },
              { name: "DateCreated", type: :date_time },
              { name: "DatePaid", type: :date_time },
            ]}
          ]},
          { name: "ShippingSignature" },
          { name: "RealtimeConfirmation" },
          { name: "InternalOrderNotes" },
          { name: "CompleteStatus" },
          { name: "UserGroup" },
          { name: "StickyNotes", type: :array, of: :object, parse_output: :item_array_wrap, properties: [
            { name: "Title" },
            { name: "Description" }
          ]}
        ]
      }
    }
  },

  test: ->(connection) {
    post("https://#{connection['domain']}.neto.com.au/do/WS/NetoAPI").headers('NETOAPI_ACTION': 'GetCustomer')
  },

  triggers: {

    new_updated_customer: {
      description: 'New or Updated <span class="provider">customer</span> in <span class="provider">Neto</span>',

      input_fields: ->() {
        [
          {
            name: 'since',
            type: :timestamp,
            hint: 'Defaults to customer updated after the recipe is first started'
          }
        ]
      },

      poll: ->(connection, input, next_poll) {
        page = next_poll.present? ? next_poll[0] : 0
        updated_time = next_poll[1] if next_poll.present?
        limit = 50
        updated_since = (updated_time || input['since'] || Time.now - 1.hours).to_time.utc

        payload = {
          "filter" => {
            "DateUpdatedFrom" => (updated_since).utc.strftime("%F %T"),
            "Page" => page,
            "Limit" => limit,
            "OutputSelector" => ["Username", "ID", "EmailAddress", "DateUpdated", "DateAdded"]
          },
        }

        customers = post("https://#{connection['domain']}.neto.com.au/do/WS/NetoAPI", payload).
                      headers('NETOAPI_ACTION': 'GetCustomer')['Customer']

        can_poll_more = customers.length >= limit

        {
          events: customers,
          next_poll: (can_poll_more ? [page + 1, updated_since] : [nil, Time.now]),
          can_poll_more: can_poll_more
        }
      },

      dedup: ->(customer) {
        customer['ID'] + "@" + customer['DateUpdated']
      },

      output_fields: ->(object_definitions) {
        object_definitions['customer']
      }
    },

    new_updated_order: {
      description: 'New or Updated <span class="provider">order</span> in <span class="provider">Neto</span>',

      input_fields: ->() {
        [
          {
            name: 'since',
            type: :timestamp,
            hint: 'Defaults to customer updated after the recipe is first started'
          }
        ]
      },

      poll: ->(connection, input, next_poll) {
        page = next_poll.present? ? next_poll[0].to_i : 0
        updated_time = next_poll[1] if next_poll.present?
        limit = 10
        updated_since = (updated_time || input['since'] || Time.now - 1.hours).to_time.utc

        payload = {
          "filter" => {
            "DateUpdatedFrom" => (updated_since).utc.strftime("%F %T"),
            "Page" => page,
            "Limit" => limit,
            "OutputSelector" => [
              "ID","ShippingOption","DeliveryInstruction","Username",
              "Email","ShipAddress","BillAddress","PurchaseOrderNumber",
              "CustomerRef1","CustomerRef2","CustomerRef3","CustomerRef4",
              "SalesChannel","GrandTotal","TaxInclusive","OrderTax",
              "SurchargeTotal","SurchargeTaxable","ProductSubtotal",
              "ShippingTotal","ShippingTax","ClientIPAddress","CouponCode",
              "CouponDiscount","ShippingDiscount","OrderType","OrderStatus",
              "OrderPayment","OrderPayment.PaymentType","OrderPayment.DatePaid",
              "DateUpdated","DatePlaced","DateRequired","DateInvoiced",
              "DatePaid","DateCompleted","OrderLine","OrderLine.ProductName",
              "OrderLine.ItemNotes","OrderLine.PickQuantity","OrderLine.BackorderQuantity",
              "OrderLine.UnitPrice","OrderLine.Tax","OrderLine.TaxCode",
              "OrderLine.WarehouseID","OrderLine.WarehouseName",
              "OrderLine.WarehouseReference","OrderLine.Quantity","OrderLine.PercentDiscount",
              "OrderLine.ProductDiscount","OrderLine.CouponDiscount","OrderLine.CostPrice",
              "OrderLine.ShippingMethod","OrderLine.ShippingTracking","OrderLine.Weight",
              "OrderLine.Cubic","OrderLine.Extra","ShippingSignature","RealtimeConfirmation",
              "InternalOrderNotes","OrderLine.eBay.eBayUsername","OrderLine.eBay.eBayStoreName",
              "OrderLine.eBay.eBayTransactionID","OrderLine.eBay.eBayAuctionID",
              "OrderLine.eBay.ListingType","OrderLine.eBay.DateCreated","CompleteStatus",
              "OrderLine.eBay.DatePaid","UserGroup","StickyNotes"
            ]
          },
        }

        can_poll_more = orders.length >= limit

        {
          events: orders,
          next_poll: (can_poll_more ? [page + 1, updated_since] : [nil, Time.now]),
          can_poll_more: can_poll_more
        }
      },

      dedup: ->(order) {
        order['ID'] + "@" + order['DateUpdated']
      },

      output_fields: ->(object_definitions) {
        object_definitions['order']
      }
    }
  }
}
