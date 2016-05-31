{
  title: 'Shipwire',

  connection: {
    fields: [
      { name: 'username' },
      { name: 'password', control_type: 'password' }
    ],

    authorization: {
      type: 'basic_auth',

      credentials: ->(connection) {
        user(connection['username'])
        password(connection['password'])
      }
    }
  },

  test: ->(connection) {
    get("https://api.shipwire.com/api/v3/products")
  },

  object_definitions: {
    product: {
      fields: ->() {
        [
          {	name: 'id'},
          {	name: 'externalId'},
          { name: 'sku'},
          {	name: 'description'},
          {	name: 'hsCode'},
          {	name: 'countryOfOrigin'},
          {	name: 'creationDate', type: :timestamp},
          {	name: 'archivedDate', type: :timestamp},
          {	name: 'status'},
          {	name: 'storageConfiguration'},
          {	name: 'batteryConfiguration'},
          {	name: 'itemCount'},
          {	name: 'vendorID'},
          {	name: 'vendorExternalId'},
          {	name:	'dimensions', type: :object, properties: [{	name: 'resourceLocation'}]},
          {	name: 'values', type: :object, properties: [{name: 'resourceLocation'}]},
          {	name: 'alternateNames', type: :object, properties: [{	name: 'resourceLocation'}]},
          {	name: 'technicalData', type: :object, properties: [{	name: 'resourceLocation'}]},
          {	name: 'flags', type: :object, properties: [{	name: 'resourceLocation'}]},
          {	name: 'enqueuedDimentions', type: :object, properties: [{	name: 'resourceLocation'}]},
          {	name: 'innerPack', type: :object, properties: [{	name: 'resourceLocation'}]},
          {	name: 'masterCase', type: :object, properties: [{	name: 'resourceLocation'}]},
          {	name: 'pallet', type: :object, properties: [{	name: 'resourceLocation'}]}
        ]
      }
    },
    
    order: {
      fields: ->() {
      	[
          { name:"resourceLocation" },
          { name:"resource", type: :object, properties: [
            { name:"id", type: :integer },
            { name:"externalId", type: :integer },
            { name:"transactionId" },
            { name:"orderNo" },
            { name:"processAfterDate", type: :datetime },
            { name:"needsReview", type: :integer },
            { name:"commerceName" },
            { name:"status" },
            { name:"lastUpdatedDate", type: :datetime },
            { name:"options", type: :object, properties: [
              { name:"resourceLocation" },
              { name:"resource", type: :object, properties: [
                { name:"warehouseId", type: :integer },
                { name:"warehouseExternalId", type: :integer },
                { name:"warehouseRegion" },
                { name:"warehouseArea" },
                { name:"serviceLevelCode" },
                { name:"carrierCode" },
                { name:"carrierAccountNumber" },
                { name:"sameDay" },
                { name:"channelName" },
                { name:"forceDuplicate", type: :integer },
                { name:"forceAddress", type: :integer },
                { name:"referrer" }
              ]}
            ]},
            { name:"pricing", type: :object, properties: [
              { name:"resourceLocation" },
              { name:"resource", type: :object, properties: [
                { name:"shipping", type: :integer },
                { name:"packaging", type: :integer },
                { name:"insurance", type: :integer },
                { name:"handling", type: :integer },
                { name:"total", type: :integer }
              ]}
            ]},
            { name:"shipFrom", type: :object, properties: [
              { name:"resourceLocation" },
              { name:"resource", type: :object, properties: [
                { name:"company" }
              ]}
            ]},
            { name:"shipTo", type: :object, properties: [
              { name:"resourceLocation" },
              { name:"resource", type: :object, properties: [
                { name:"email" },
                { name:"name" },
                { name:"company" },
                { name:"address1" },
                { name:"address2" },
                { name:"address3" },
                { name:"city" },
                { name:"state" },
                { name:"postalCode" },
                { name:"country" },
                { name:"phone" },
                { name:"isCommercial", type: :integer },
                { name:"isPoBox", type: :integer }
              ]}
            ]},
            { name:"events", type: :object, properties: [
              { name:"resourceLocation" },
              { name:"resource", type: :object, properties: [
                { name:"createdDate", type: :datetime },
                { name:"pickedUpDate", type: :datetime },
                { name:"submittedDate", type: :datetime },
                { name:"processedDate", type: :datetime },
                { name:"completedDate", type: :datetime },
                { name:"expectedDate", type: :datetime },
                { name:"cancelledDate", type: :datetime },
                { name:"returnedDate", type: :datetime },
                { name:"lastManualUpdateDate", type: :datetime }
              ]}
            ]}
          ]}
        ]  
      }
    }
  },

  actions: {
    
    search_products: {
      input_fields: ->() {
        [
          { name: 'sku', label: 'SKU' },
          { name: 'description' }
        ]
      },
      execute: ->(connection,input) {
        { 
          'items': get("https://api.shipwire.com/api/v3/products", input)['resource']['items']
        }
      },
      output_fields: ->(object_definitions) {
       [
         { name: 'items', type: :array, of: :object, properties: [
            { name: 'resourceLocation', control_type: 'url' },
            { name: 'resource', type: :object, properties: object_definitions['product'] }
         ]}
       ]
      }
    },
    
    get_product_details: {
    	input_fields: ->() {
      	[
          {name: 'ProductID', optional: :false}
        	]	  
      },
      
      execute: ->(connection, input) {
        	product_detail = get("https://api.shipwire.com/api/v3/products/#{input['ProductID']}")
        },
      
      output_fields: ->(object_definitions) {
        	[
        		{	name: 'status'},
            {	name: 'message'},
            {	name: 'resourceLocation'},
            {	name: 'resource', type: :object, properties: object_definitions['product']}
        	]
        }
    }
  },

  triggers: {

		new_or_updated_order: {
#     	type: :paging_desc,

    	input_fields: ->() {
      	[
        	{ name: 'since', type: :timestamp },
          {	name: 'status', control_type: 'select', hint: 'type of order to be tracked. Leave blank to track all orders',
            	picklist: [['processed'],['canceled'], ['completed'], ['delivered'], ['returned'], ['submitted'], ['held'], ['tracked']]}
        ]
      },

      poll: ->(connection,input,last_updated_since) {
        since = last_updated_since || input['since'] || Time.now

        result = get("https://api.shipwire.com/api/v3/orders").
          				params(updatedAfter: since.to_time.utc.iso8601,
                    		 status: input['status'])['resource']
        
        orders = result['items']
        
        next_updated_since = orders.first['resource']['lastUpdatedDate'] unless orders.length == 0
        
        {
          events: orders,
          next_page: next_updated_since,
          can_poll_more: result['total'] > orders.length + result['offset']
        }
      },

#       document_id: ->(order) {
#         order['resource']['id']
#       },

#       sort_by: ->(order) { order['resource']['id'] },

      dedup: ->(order) {
        order['resource']['id']
      },

      output_fields: ->(object_definitions) {
				object_definitions['order']
      }
    }
  }
}
