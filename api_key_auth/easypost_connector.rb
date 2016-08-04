{
  title: 'easypost',

  connection: {
    fields: [
      {
        name: 'username',
        control_type: 'password',
        optional: false,
        hint: 'Your API key below'
      }
    ],
    
    authorization: {
      type: 'api_key',
      credentials: ->(connection) {
        user(connection['username'])
      }
    }
  },
  
   object_definitions: {
    address: {
      fields: ->() {
        [
          { name: 'id', hint: "Generated automatically" },
          { name: 'street1', optional: false },
          { name: 'street2', optional: false },
          { name: 'city', optional: false },
          { name: 'state', optional: false },
          { name: 'zip', type: :integer, optional: false },
          { name: 'country', optional: false },
          { name: 'name', optional: false },
          { name: 'company', optional: false },
          { name: 'phone', control_type: :phone, optional: false },
          { name: 'email', control_type: :email, optional: false },
          { name: 'residential', type: :boolean },
          { name: 'carrier_facility' },
          { name: 'federal_tax_id', type: :integer },
          { name: 'state_tax_id', type: :integer },
          { name: 'verifications', type: :object, properties: [
            { name: 'zip4', type: :object, properties: [
              { name: 'success', type: :boolean},
              { name: 'errors', type: :array}]},
            { name: 'delivery', type: :object, properties: [
              { name: 'success', type: :boolean},
              { name: 'errors', type: :array}
              ]}
           ]}
         ]     
      },
    },
     users: {
      fields: ->() {
        [
          { name: 'id', hint: "generated automatically" },
          { name: 'object' },
          { name: 'parent_id' },         
          { name: 'name', optional: false },  
          { name: 'email', optional: false },
          { name: 'phone_number' },
          { name: 'balance' },
          { name: 'recharge_amount' },
          { name: 'secondary_recharge_amount' },
          { name: 'recharge_threshold' },
          { name: 'children', type: :array, of: :objects, properties: [
            { name: 'id' },
          	{ name: 'object' },
          	{ name: 'parent_id' },         
          	{ name: 'name' },  
          	{ name: 'email' },
          	{ name: 'phone_number' },
         		{ name: 'balance' },
          	{ name: 'recharge_amount' },
          	{ name: 'secondary_recharge_amount' },
          	{ name: 'recharge_threshold' },
          	{ name: 'children' }]}
         ] 
      },
    },
     tracker: {
      fields: ->() {
        [
          { name: 'id', hint: "generated automatically" },
          { name: 'object' },
          { name: 'mode' },         
          { name: 'tracking_code', optional: false },  
          { name: 'status' },
          { name: 'signed_by' },
          { name: 'weight', type: :integer },
          { name: 'est_delivery_date', type: :datetime },
          { name: 'shipment_id' },
          { name: 'carrier' },
          { name: 'tracking_details', type: :array, of: :objects, properties: [
          	{ name: 'object' },
          	{ name: 'message' },         
          	{ name: 'status' },  
          	{ name: 'datetime' },
          	{ name: 'source' },
         		{ name: 'tracking_location', type: :array, of: :objects, properties: [
              { name: 'object' },
          		{ name: 'city' },
          		{ name: 'state' },
          		{ name: 'country' },
              { name: 'zip' }]}]},
          { name: 'carrier_detail', type: :array, of: :objects, properties: [
            { name: 'object' },
          	{ name: 'service' },
          	{ name: 'container_type' },
         		{ name: 'est_delivery_date_local' },
            { name: 'est_delivery_time_local' }]},
          { name: 'fees', type: :array, of: :objects, properties: [
            { name: 'object' },
         		{ name: 'type' },
        		{ name: 'amount' },
          	{ name: 'charged', type: :boolean },
            { name: 'refunded', type: :boolean }]},
          { name: 'created_at', type: :datetime },
          { name: 'updated_at', type: :datetime }
         ] 
      },
    },
     parcel: {
      fields: ->() {
        [
          { name: 'id', hint: "Generated automatically" },
          { name: 'object' },
          { name: 'mode' },         
          { name: 'length', type: :integer, optional: false },  
          { name: 'width', type: :integer, optional: false },
          { name: 'height', type: :integer, optional: false },
          { name: 'predefined_package' },
          { name: 'weight', type: :integer, optional: false },
          { name: 'created_at', type: :datetime },
          { name: 'updated_at', type: :datetime }
        ] 
      },
    },
     
     rates: {
      fields: ->() {
        [
          { name: 'id', hint: "generated automatically" },
          { name: 'object' },
         	{ name: 'mode' },
       		{ name: 'service' },
     			{ name: 'carrier' },
       		{ name: 'carrier_account_id', type: :integer },
       		{ name: 'shipment_id' },
        	{ name: 'rate' },
       		{ name: 'currency' },
       		{ name: 'retail_rate' },
     			{ name: 'retail_currency' },
       		{ name: 'list_rate' },
       		{ name: 'list_currency' },
        	{ name: 'delivery_days', type: :integer },
       		{ name: 'delivery_date' },
         	{ name: 'delivery_date_guaranteed', type: :boolean },
       		{ name: 'est_delivery_days', type: :integer },
       		{ name: 'created_at', type: :datetime },
       		{ name: 'updated_at', type: :datetime }
        ] 
      },
    },
     
     shipments: {
      fields: ->() {
        [
          { name: 'id' },
          { name: 'object' },
          { name: 'reference' },
          { name: 'mode' },  
          { name: 'to_address', type: :object, properties: [
           	{ name: 'id' },
         		{ name: 'street1' },
         		{ name: 'street2' },
         		{ name: 'city' },
         		{ name: 'state' },
         		{ name: 'zip', type: :integer },
         		{ name: 'country' },
        		{ name: 'name' },
         		{ name: 'company' },
            { name: 'phone', control_type: :phone },
          	{ name: 'email', control_type: :email },
         		{ name: 'residential', type: :boolean },
         		{ name: 'carrier_facility' },
         		{ name: 'federal_tax_id', type: :integer },
         		{ name: 'state_tax_id', type: :integer },
         		{ name: 'verifications', type: :object, properties: [
           		{ name: 'zip4', type: :object, properties: [
             		{ name: 'success', type: :boolean},
             		{ name: 'errors', type: :array}]},
            	{ name: 'zip4', type: :object, properties: [
              	{ name: 'success', type: :boolean},
              	{ name: 'errors', type: :array}]}
            	]}
            ]},
          { name: 'from_address', type: :object, properties:  [
            { name: 'id' },
          	{ name: 'street1' },
          	{ name: 'street2' },
          	{ name: 'city' },
          	{ name: 'state' },
          	{ name: 'zip', type: :integer },
          	{ name: 'country' },
          	{ name: 'name' },
          	{ name: 'company' },
          	{ name: 'phone', control_type: :phone },
          	{ name: 'email', control_type: :email },
          	{ name: 'residential', type: :boolean },
          	{ name: 'carrier_facility' },
          	{ name: 'federal_tax_id', type: :integer },
          	{ name: 'state_tax_id', type: :integer },
          	{ name: 'verifications', type: :object, properties: [
            	{ name: 'zip4', type: :object, properties: [
              	{ name: 'success', type: :boolean},
              	{ name: 'errors', type: :array}]},
            	{ name: 'zip4', type: :object, properties: [
              	{ name: 'success', type: :boolean},
              	{ name: 'errors', type: :array}]}
            	]}
            ]},
          { name: 'return_address', type: :object, properties:  [
            { name: 'id' },
          	{ name: 'street1' },
          	{ name: 'street2' },
          	{ name: 'city' },
          	{ name: 'state' },
          	{ name: 'zip', type: :integer },
          	{ name: 'country' },
          	{ name: 'name' },
          	{ name: 'company' },
         		{ name: 'phone', control_type: :phone },
         		{ name: 'email', control_type: :email },
         		{ name: 'residential', type: :boolean },
         		{ name: 'carrier_facility' },
         		{ name: 'federal_tax_id', type: :integer },
         		{ name: 'state_tax_id', type: :integer },
         		{ name: 'verifications', type: :object, properties: [
           		{ name: 'zip4', type: :object, properties: [
             		{ name: 'success', type: :boolean},
             		{ name: 'errors', type: :array}]},
           		{ name: 'zip4', type: :object, properties: [
             		{ name: 'success', type: :boolean},
             		{ name: 'errors', type: :array}]}
           		]}
           	]},
         	{ name: 'buyers_address', type: :object, properties:  [
           	{ name: 'id' },
         		{ name: 'street1' },
          	{ name: 'street2' },
          	{ name: 'city' },
         		{ name: 'state' },
         		{ name: 'zip', type: :integer },
         		{ name: 'country' },
         		{ name: 'name' },
         		{ name: 'company' },
         		{ name: 'phone', control_type: :phone },
         		{ name: 'email', control_type: :email },
         		{ name: 'residential', type: :boolean },
         		{ name: 'carrier_facility' },
          	{ name: 'federal_tax_id', type: :integer },
          	{ name: 'state_tax_id', type: :integer },
         		{ name: 'verifications', type: :object, properties: [
           		{ name: 'zip4', type: :object, properties: [
             		{ name: 'success', type: :boolean},
             		{ name: 'errors', type: :array}]},
           		{ name: 'zip4', type: :object, properties: [
             		{ name: 'success', type: :boolean},
             		{ name: 'errors', type: :array}]}
           		]}
           	]},
          { name: 'parcel', type: :object, properties: [
            { name: 'id' },
         		{ name: 'object' },
         		{ name: 'mode' },         
         		{ name: 'length', type: :integer },  
         		{ name: 'width', type: :integer },
       			{ name: 'height', type: :integer },
         		{ name: 'predefined_package' },
         		{ name: 'weight', type: :integer },
         		{ name: 'created_at', type: :datetime },
       			{ name: 'updated_at', type: :datetime }]},
         	{ name: 'customs_info', type: :object, properties: [
            { name: 'id' },
         		{ name: 'object' },
         		{ name: 'eel_pfc' },         
        		{ name: 'contents_type' },  
         		{ name: 'contents_expalanation' },
          	{ name: 'customs_certify', type: :boolean },
          	{ name: 'customs_signer' },
         		{ name: 'non_delivery_option' },
            { name: 'restriction_type' },
       			{ name: 'restriction_comments' },  
       			{ name: 'customs_items', type: :object, properties: [
              { name: 'id' },
         			{ name: 'object' },
         			{ name: 'description' },         
         			{ name: 'quantity' },  
              { name: 'value' },
          		{ name: 'weight', type: :boolean },
          		{ name: 'hs_tariff_number' },
          		{ name: 'origin_country' },
             	{ name: 'currency' },
       				{ name: 'created_at', type: :datetime },
       				{ name: 'updated_at', type: :datetime }
             ]},
         		{ name: 'created_at', type: :datetime },
          	{ name: 'updated_at', type: :datetime }]},
          { name: 'scan_form', type: :object, properties: [
            { name: 'id' },
          	{ name: 'object' },
          	{ name: 'status' },         
         		{ name: 'message' },  
       			{ name: 'address', type: :object, properties: [
              { name: 'id', optional: :false },
         			{ name: 'street1' },
         			{ name: 'street2' },
         			{ name: 'city' },
       				{ name: 'state' },
       				{ name: 'zip', type: :integer },
       				{ name: 'country' },
          		{ name: 'name' },
          		{ name: 'company' },
          		{ name: 'phone', control_type: :phone },
         			{ name: 'email', control_type: :email },
       				{ name: 'residential', type: :boolean },
       				{ name: 'carrier_facility' },
         			{ name: 'federal_tax_id', type: :integer },
         			{ name: 'state_tax_id', type: :integer },
         			{ name: 'verifications', type: :object, properties: [
           			{ name: 'zip4', type: :object, properties: [
             			{ name: 'success', type: :boolean},
             			{ name: 'errors', type: :array}]},
           		  { name: 'zip4', type: :object, properties: [
             			{ name: 'success', type: :boolean},
             			{ name: 'errors', type: :array}]}
           			]}
               ]},
       			{ name: 'tracking_codes' },
         		{ name: 'form_url' },
         		{ name: 'form_file_type' },
            { name: 'batch_id' },
       			{ name: 'created_at', type: :datetime },
       			{ name: 'updated_at', type: :datetime }]},
         	{ name: 'forms' },
          { name: 'insurance', type: :object, properties: [
            { name: 'amount' }]},
         	{ name: 'rates', type: :object, properties: [
            { name: 'id', optional: :false },
          	{ name: 'object' },
          	{ name: 'mode' },
         		{ name: 'service' },
       			{ name: 'carrier' },
         		{ name: 'carrier_account_id', type: :integer },
         		{ name: 'shipment_id' },
         		{ name: 'rate' },
       			{ name: 'currency' },
       			{ name: 'retail_rate' },
       			{ name: 'retail_currency' },
         		{ name: 'list_rate' },
         		{ name: 'list_currency' },
         		{ name: 'delivery_days', type: :integer },
         		{ name: 'delivery_date' },
           	{ name: 'delivery_date_guaranteed', type: :boolean },
         		{ name: 'est_delivery_days', type: :integer },
         		{ name: 'created_at', type: :datetime },
         		{ name: 'updated_at', type: :datetime }]},
         	{ name: 'selected_rate', type: :object, properties: [
            { name: 'id', optional: :false },
         		{ name: 'object' },
         		{ name: 'mode' },
         		{ name: 'service' },
         		{ name: 'carrier' },
        		{ name: 'carrier_account_id', type: :integer },
         		{ name: 'shipment_id' },
         		{ name: 'rate' },
       			{ name: 'currency' },
       			{ name: 'retail_rate' },
       			{ name: 'retail_currency' },
       			{ name: 'list_rate' },
         		{ name: 'list_currency' },
         		{ name: 'delivery_days', type: :integer },
         		{ name: 'delivery_date' },
           	{ name: 'delivery_date_guaranteed', type: :boolean },
         		{ name: 'est_delivery_days', type: :integer },
         		{ name: 'created_at', type: :datetime },
         		{ name: 'updated_at', type: :datetime }]},
         	{ name: 'postage_label' },
          { name: 'messages', type: :object, properties: [
            { name: 'carrier' },
            { name: 'type' },
            { name: 'message' }]},
         	{ name: 'options', type: :object, properties: [
            { name: 'additional_handling', type: :boolean },
         		{ name: 'address_validation_level' },
         		{ name: 'alcohol', type: :boolean },
       			{ name: 'bill_receiver_amount' },
       			{ name: 'bill_receiver_postal_code' },
       			{ name: 'bill_third_party_account' },
       			{ name: 'bill_third_party_country' },
         		{ name: 'bill_third_party_postal_code' },
         		{ name: 'by_drone', type: :boolean },
         		{ name: 'carbon_neutral', type: :boolean },
       			{ name: 'cod_amount' },
            { name: 'cod_amount' },
          	{ name: 'currency' },
         		{ name: 'delivery_duty_paid', type: :boolean },
       			{ name: 'delivery_confirmation' },
         		{ name: 'dry_ice', type: :boolean },
       			{ name: 'dry_ice_weight' },
           	{ name: 'freight_charge', type: :integer },
           	{ name: 'handling_instructions' },
            { name: 'hazmat' },
       			{ name: 'hold_for_pickup', type: :boolean },
       			{ name: 'invoice_number' },
       			{ name: 'label_date' },
        		{ name: 'label_format' },
          	{ name: 'machinable', type: :boolean },
          	{ name: 'print_custom_1' },
         		{ name: 'print_custom_2' },
       			{ name: 'print_custom_3' },
       			{ name: 'print_custom_1_barcode', type: :boolean },
       			{ name: 'print_custom_2_barcode', type: :boolean },
       			{ name: 'print_custom_3_barcode', type: :boolean },
            { name: 'print_custom_1_code' },
         		{ name: 'print_custom_2_code' },
         		{ name: 'print_custom_3_code' },
          	{ name: 'saturday_delivery', type: :boolean },
         		{ name: 'special_rates_eligibility' },
            { name: 'smartpost_hub' },
           	{ name: 'smartpost_manifest' }]},
          { name: 'is_return',type: :boolean },
          { name: 'tracking_code' },
          { name: 'usps_zone' },
          { name: 'status' },
          { name: 'tracker', type: :object, properties: [
            { name: 'id' },
         		{ name: 'object' },
         		{ name: 'mode' },         
         		{ name: 'tracking_code' },  
         		{ name: 'status' },
         		{ name: 'signed_by' },
         		{ name: 'weight', type: :integer },
          	{ name: 'est_delivery_date', type: :datetime },
          	{ name: 'shipment_id' },
          	{ name: 'carrier' },
         		{ name: 'tracking_details', type: :array, of: :objects, properties: [
         			{ name: 'object' },
         			{ name: 'message' },         
         			{ name: 'status' },  
         			{ name: 'datetime' },
         			{ name: 'source' },
       				{ name: 'tracking_location', type: :array, of: :objects, properties: [
             		{ name: 'object' },
          			{ name: 'city' },
          			{ name: 'state' },
          			{ name: 'country' },
           			{ name: 'zip' }]}
                ]},
         		{ name: 'carrier_detail', type: :array, of: :objects, properties: [
          		{ name: 'object' },
         			{ name: 'service' },
         			{ name: 'container_type' },
       				{ name: 'est_delivery_date_local' },
          		{ name: 'est_delivery_time_local' }]},
         		{ name: 'fees', type: :array, of: :objects, properties: [
          		{ name: 'object' },
        			{ name: 'type' },
        			{ name: 'amount' },
          		{ name: 'charged', type: :boolean },
           		{ name: 'refunded', type: :boolean }]},
         		{ name: 'created_at', type: :datetime },
       	 		{ name: 'updated_at', type: :datetime }]},
          { name: 'fees', type: :object, properties: [
            { name: 'object' },
        		{ name: 'type' },
       			{ name: 'amount' },
         		{ name: 'charged', type: :boolean },
         		{ name: 'refunded', type: :boolean }]},
         	{ name: 'refund_status' },
         	{ name: 'batch_id' },
          { name: 'batch_status' },
         	{ name: 'batch_message' },
         	{ name: 'created_at', type: :datetime },
         	{ name: 'updated_at', type: :datetime },
       	]
      },
    },
     },

  test: ->(connection) {
    get("https://easypost.com/v2/addresses")
  },

  actions: {
    create_address: { 
      input_fields: ->(object_definitions) {
        [
          { name: 'street1', optional: false },
          { name: 'street2', optional: false },
          { name: 'city', optional: false },
          { name: 'state', optional: false },
          { name: 'zip', type: :integer, optional: false },
          { name: 'country', optional: false },
          { name: 'name', optional: false },
          { name: 'company', optional: false },
          { name: 'phone', control_type: :phone, optional: false },
          { name: 'email', control_type: :email, optional: false },
          { name: 'residential', type: :boolean },
          { name: 'carrier_facility' },
          { name: 'federal_tax_id', type: :integer },
          { name: 'state_tax_id', type: :integer },
          { name: 'verify' }
          ]
      },
      execute: ->(connection, input) {
        input['verify'] = [input['verify']]
        post("https://api.easypost.com/v2/addresses", input )
      },
      output_fields: ->(object_definitions) {
        [
					{ name: 'addresses', type: :object, properties: object_definitions['address'] }
        ]
        }
    },
    
    retreive_address_by_id: {
      input_fields: ->(object_definitions) {
        [
          { name: "id", label: "ID", optional: false, hint: "ID of the address to be retreived" }
        ]
      },
      execute: ->(connection, input) {
        {
       'addresses': get("https://api.easypost.com/v2/addresses/#{input['id']}", { address: input } )
        }
      },
      output_fields: ->(object_definitions) {
				[
					{ name: 'addresses', type: :object, properties: object_definitions['address'] }
        ]
      }
    },
    
    create_parcel: { 
      input_fields: ->(object_definitions) {
        [
          { name: 'length', type: :integer, optional: false, label: "Length of the parcel" },  
          { name: 'width', type: :integer, optional: false, label: "Width of the parcel" },
          { name: 'height', type: :integer, optional: false, label: "Height of the parcel" },
          { name: 'predefined_package' },
          { name: 'weight', type: :integer, optional: false, label: "Weight of the parcel" }
        ]
      },
      execute: ->(connection, input) {       
        post("https://easypost.com/v2/parcels", input )
      },
      output_fields: ->(object_definitions) {
        object_definitions['parcel']
        }
    },
    
    retreive_parcel_by_id: {
      input_fields: ->(object_definitions) {
        [
          { name: "id", label: "parcel ID", hint: "ID of the parcel to be retreived", optional: false }
        ]
      },
      execute: ->(connection, input) {
        get("https://api.easypost.com/v2/parcels/#{input['id']}")
      },
      output_fields: ->(object_definitions) {
        object_definitions['parcel']
      }
    },
    
    create_shipment: { 
      input_fields: ->(object_definitions) {
        
        [
          { name: "to_address_id", label: "ID", hint: "use ID if address exists or create a new one" },
          { name: 'name' },
          { name: 'street1' },
          { name: 'street2' },
          { name: 'city' },
          { name: 'state' },
          { name: 'zip', type: :integer },
          { name: 'country' },
          { name: 'phone', control_type: :phone },
          { name: 'email', control_type: :email },
          { name: "from_address_id", label: "ID", hint: "use ID if address exists or create a new one" },
          { name: 'street1' },
          { name: 'street2' },
          { name: 'city' },
          { name: 'state' },
          { name: 'zip', type: :integer },
          { name: 'country' },
          { name: 'name' },
          { name: 'company' },
          { name: 'phone', control_type: :phone },
          { name: 'email', control_type: :email },
          { name: "parcel_id", label: "ID", hint: "use ID if parcel exists or create a new one", optional: false },
          { name: 'length', type: :integer },  
          { name: 'width', type: :integer },
          { name: 'height', type: :integer },
          { name: 'weight', type: :integer },
          { name: 'customs_info' }
        ]
      },
      execute: ->(connection, input) {       
        hash = {
          "to_address" => {'id' => input['to_address']},
          "to_address" => {'name' => input['name']},
          "to_address" => {'street1' => input['street1']},
          "to_address" => {'street2' => input['street2']},
          "to_address" => {'city' => input['city']},
          "to_address" => {'state' => input['state']},
          "to_address" => {'zip' => input['zip']},
          "to_address" => {'country' => input['country']},
          "to_address" => {'phone' => input['phone']},
          "to_address" => {'email' => input['email']},
          "from_address" => {'id' => input['from_address']},
          "from_address" => {'name' => input['name']},
          "from_address" => {'street1' => input['street1']},
          "from_address" => {'street2' => input['street2']},
          "from_address" => {'city' => input['city']},
          "from_address" => {'state' => input['state']},
          "from_address" => {'zip' => input['zip']},
          "from_address" => {'country' => input['country']},
          "from_address" => {'phone' => input['phone']},
          "from_address" => {'email' => input['email']},
          "parcel" => {'id' => input['parcel']},
          "parcel" => {'length' => input['length']},
          "parcel" => {'width' => input['width']},
          "parcel" => {'height' => input['height']},
          "parcel" => {'weight' => input['weight']},
          "customs_info" => {'id' => input['customs_info']}
          }
        post("https://easypost.com/v2/shipments").params(shipment: hash)
      },
      output_fields: ->(object_definitions) {
        object_definitions['shipments']
        }
    },
    
    retreive_shipment_by_id: {
      input_fields: ->(object_definitions) {
        [
          { name: "id", label: "ID", hint: "ID of the shipment to be retreived", optional: false }
        ]
      },
      execute: ->(connection, input) {
        get("https://api.easypost.com/v2/shipments/#{input['id']}" )
      },
      output_fields: ->(object_definitions) {
        object_definitions['shipments']
      }
    },
    
    buy_shipment: {
      input_fields: ->(object_definitions) {
        [
          { name: "id", label: "ID", hint: "Shipment ID", optional: false },
          { name: "rate", label: "ID", hint: "Rate ID", optional: false },
          { name: "insurance", label: "Insurance", hint: "Amount to be insured", optional: false }
        ]
      },
      execute: ->(connection, input) {
        hash = {
          "id" => input["rate"] 
          }
        post("https://api.easypost.com/v2/shipments/#{input['id']}/buy",input ).params(rate: hash)
      },
      output_fields: ->(object_definitions) {
        object_definitions['shipments']
      }
    },
    
    convert_the_label_format_of_a_shipment: {
      input_fields: ->(object_definitions) {
        [
          { name: "id", label: "ID", hint: "ID of the shipment", optional: false },
          { name: "file_format", optional: false }
        ]
      },
      execute: ->(connection, input) {   
        get("https://api.easypost.com/v2/shipments/#{input['id']}/label",input )
      },
      output_fields: ->(object_definitions) {
        object_definitions['shipments']
      }
    },
    
    create_a_shipment_with_options: {
      input_fields: ->(object_definitions) {
        [
          { name: "to_address", hint:"ID of the receiver's address", label: "ID", optional: false },
          { name: "from_address", hint:"ID of the sender's address", label: "ID", optional: false },
          { name: "parcel", hint:"ID of the parcel to be shipped", label: "ID", optional: false },
          { name: 'additional_handling', type: :boolean },
          { name: 'address_validation_level' },
         	{ name: 'alcohol', type: :boolean },
       		{ name: 'bill_receiver_amount' },
     			{ name: 'bill_receiver_postal_code' },
     			{ name: 'bill_third_party_account' },
       		{ name: 'bill_third_party_country' },
         	{ name: 'bill_third_party_postal_code' },
       		{ name: 'by_drone', type: :boolean },
       		{ name: 'carbon_neutral', type: :boolean },
     			{ name: 'cod_amount' },
          { name: 'cod_method' },
          { name: 'currency' },
         	{ name: 'delivery_duty_paid', type: :boolean },
       		{ name: 'delivery_confirmation' },
       		{ name: 'dry_ice', type: :boolean },
     			{ name: 'dry_ice_weight' },
         	{ name: 'freight_charge', type: :integer },
          { name: 'handling_instructions' },
          { name: 'hazmat' },
       		{ name: 'hold_for_pickup', type: :boolean },
      		{ name: 'invoice_number' },
       		{ name: 'label_date' },
          { name: 'label_format' },
         	{ name: 'machinable', type: :boolean },
         	{ name: 'print_custom_1' },
       		{ name: 'print_custom_2' },
     			{ name: 'print_custom_3' },
     			{ name: 'print_custom_1_barcode', type: :boolean },
     			{ name: 'print_custom_2_barcode', type: :boolean },
       		{ name: 'print_custom_3_barcode', type: :boolean },
          { name: 'print_custom_1_code' },
       		{ name: 'print_custom_2_code' },
       		{ name: 'print_custom_3_code' },
          { name: 'saturday_delivery', type: :boolean },
         	{ name: 'special_rates_eligibility' },
          { name: 'smartpost_hub' },
         	{ name: 'smartpost_manifest' }
        ]
      },
      execute: ->(connection, input) {   
        hash = {
          "to_address" => {'id' => input['to_address']},
          "from_address" => {'id' => input['from_address']},
          "parcel" => {'id' => input['parcel']},
          "options" => {  'additional_handling' => input['additional_handling'],
            						  'address_validation_level' => input['address_validation_level'],
            						  'alcohol' => input['alcohol'],
            						  'bill_receiver_amount' => input['bill_receiver_amount'],
            							'bill_receiver_postal_code' => input['bill_receiver_postal_code'],
            							'bill_third_party_account' => input['bill_third_party_account'],
            							'bill_third_party_country' => input['bill_third_party_country'],
            							'bill_third_party_postal_code' => input['bill_third_party_postal_code'],
            							'by_drone' => input['by_drone'],
            							'carbon_neutral' => input['carbon_neutral'],
            							'cod_amount' => input['cod_amount'],
            							'cod_method' => input['cod_method'],
            							'currency' => input['currency'],
            							'delivery_duty_paid' => input['delivery_duty_paid'],
            							'delivery_confirmation' => input['delivery_confirmation'],
            							'dry_ice' => input['dry_ice'],
            							'dry_ice_weight' => input['dry_ice_weight'],
            							'freight_charge' => input['freight_charge'],
            							'handling_instructions' => input['handling_instructions'],
            							'hazmat' => input['hazmat'],
            							'hold_for_pickup' => input['hold_for_pickup'],
            							'invoice_number' => input['invoice_number'],
            							'label_date' => input['label_date'],
            							'label_format' => input['label_format'],
            							'machinable' => input['machinable'],
            							'print_custom_1' => input['print_custom_1'],
            							'print_custom_2' => input['print_custom_2'],
           							  'print_custom_3' => input['print_custom_3'],
            							'print_custom_1_barcode' => input['print_custom_1_barcode'],
           								'print_custom_2_barcode' => input['print_custom_2_barcode'],
            							'print_custom_3_barcode' => input['print_custom_3_barcode'],
           							  'saturday_delivery' => input['saturday_delivery'],
            							'special_rates_eligibility' => input['special_rates_eligibility'],
            							'smartpost_hub' => input['smartpost_hub'],
            							'smartpost_manifest' => input['smartpost_manifest']
            }              
          }
        post("https://api.easypost.com/v2/shipments").params(shipment: hash)
      },
      output_fields: ->(object_definitions) {
        object_definitions['shipments']
      }
    },
    
    regenerate_rates_for_a_shipment: { 
      input_fields: ->(object_definitions) {
        [
          { name: "id", hint: "ID of the shipment", label: "ID", optional: false }
        ]
      },
      execute: ->(connection, input) {       
        get("https://easypost.com/v2/shipments/#{input['id']}/rates")
      },
      output_fields: ->(object_definitions) {
        object_definitions['users']
        }
    },
    
    insure_shipment: { 
      input_fields: ->(object_definitions) {
        [
          { name: "id", hint: "ID of the shipment to be insured", label: "ID", optional: false },
          { name: "amount", hint: "Amount to be insured", optional: false }
        ]
      },
      execute: ->(connection, input) {       
        post("https://easypost.com/v2/shipments/#{input['id']}/insure", input)
      },
      output_fields: ->(object_definitions) {
        object_definitions['users']
        }
    },
    
    create_a_refund: { 
      input_fields: ->(object_definitions) {
        [
          { name: "id", hint: "ID of the shipment to be refunded", label: "ID", optional: false }
        ]
      },
      execute: ->(connection, input) {       
        get("https://easypost.com/v2/shipments/#{input['id']}/refund")
      },
      output_fields: ->(object_definitions) {
        object_definitions['users']
        }
    },
    
    create_a_return_shipment: { 
      input_fields: ->(object_definitions) {
        [
          { name: "is_return", type: :boolean, optional: false },
          { name: "to_address", hint: "ID of the receiver's address", label: "ID", optional: false },
          { name: "from_address", hint: "ID of the sender's address", label: "ID", optional: false },
          { name: "parcel", hint: "ID of the parcel to be shipped", label: "ID", optional: false }
        ]
      },
      execute: ->(connection, input) {    
        hash = {
          "to_address" => { 'id' => input['to_address'] },
          "from_address" => { 'id' => input['from_address'] },
          "parcel" => { 'id' => input['parcel'] },
          "is_return" => input['is_return']
          }
        post("https://easypost.com/v2/shipments", input).params(shipment: hash)
      },
      output_fields: ->(object_definitions) {
        object_definitions['users']
        }
    },
    
    create_user: { 
      input_fields: ->(object_definitions) {
        [
          { name: 'name', optional: false },
          { name: 'password', optional: false },
          { name: 'password_confirmation', optional: false },
          { name: 'email', optional: false },
          { name: 'phone_number' },
          { name: 'balance' },
          { name: 'recharge_amount' },
          { name: 'secondary_recharge_amount' },
          { name: 'recharge_threshold' },
          { name: 'children', type: :array, of: :objects, properties: [
            { name: 'id' },
          	{ name: 'object' },
          	{ name: 'parent_id' },         
          	{ name: 'name' },  
          	{ name: 'email' },
          	{ name: 'phone_number' },
         		{ name: 'balance' },
          	{ name: 'recharge_amount' },
          	{ name: 'secondary_recharge_amount' },
          	{ name: 'recharge_threshold' },
          	{ name: 'children' }]}
        ]
      },
      execute: ->(connection, input) {       
        post("https://easypost.com/v2/users", input )
      },
      output_fields: ->(object_definitions) {
        object_definitions['users']
        }
    },
    
    retreive_user_by_id: {
      input_fields: ->(object_definitions) {
       [
         { name: "id", label: "ID", optional: false, hint: "ID of the user to be retreived" }
       ]
      },
      execute: ->(connection, input) {
        get("https://api.easypost.com/v2/users", input )
      },
      output_fields: ->(object_definitions) {
        object_definitions['users']
      }
    },
    
    update_user_by_id: {
      input_fields: ->(object_definitions) {
                [
                  { name: 'id', optional: false },         
          				{ name: 'name' },  
          				{ name: 'email' },
          				{ name: 'phone_number' },
                  { name: 'password' },
          				{ name: 'password_confirmation' },
          				{ name: 'recharge_amount' },
          				{ name: 'secondary_recharge_amount' },
          				{ name: 'recharge_threshold' }
                ]
      },
      execute: ->(connection, input) {
        
        put("https://api.easypost.com/v2/users/#{input['id']}", input )
      },
      output_fields: ->(object_definitions) {
        object_definitions['users']
      }
    },
    
    create_tracker: {
      input_fields: ->(object_definitions) {
                [
                  { name: 'tracking_code', optional: false, hint: "tracking code of package you'd like to track" },
                  { name: 'carrier', hint: "carrier associated with the tracking code" }
                ]
      },
      execute: ->(connection, input) {
        
        post("https://api.easypost.com/v2/trackers", input )
      },
      output_fields: ->(object_definitions) {
        object_definitions['tracker']
      }
    },
    
    search_tracker: {
      input_fields: ->(object_definitions) {
           [
             { name: "id", label: "ID", optional: false, hint: "ID of the tracker to be retreived" }
           ]
      },
      execute: ->(connection, input) {        
        get("https://api.easypost.com/v2/trackers/#{input['id']}")
      },
      output_fields: ->(object_definitions) {
        object_definitions['tracker']
      }
    },
    
    create_child_user: { 
      input_fields: ->(object_definitions) {
       [
         { name: 'name' }
       ]
      },
      execute: ->(connection, input) {
        post("https://easypost.com/v2/users", input )
      },
      output_fields: ->(object_definitions) {
        object_definitions['users']
        }
    }
  },
  
   triggers: {
    new_tracker: {  
      type: :paging_desc,
      
      input_fields: ->() {
        [
          {
      			name: 'after_id', label: 'ID', optional: false, hint: "Retreive trackers created after this ID"
      		},
        ]
      },
      
      poll: ->(connection,input,next_updated_since) {
        updated_since = next_updated_since || input['after_id']
        response = get("https://api.easypost.com/v2/trackers?after_id=#{updated_since}&page_size=30")
        next_updated_since = response['trackers'].last['id'] unless response['trackers'].blank?
        {
          events: response['trackers'].reverse,
          next_page: response.length >= 300 ? next_updated_since : nil
        }
      },
     
			output_fields: ->(object_definitions) {
        object_definitions['tracker']
      }
    },   
     
     new_parcel: {  
      type: :paging_desc,
      
      input_fields: ->() {
        [
          {
      			name: 'after_id', label: 'ID', optional: false, hint: "Retreive parcels created after this ID"
      		},
        ]
      },
      
      poll: ->(connection,input,next_updated_since) {
        updated_since = next_updated_since || input['after_id']
        response = get("https://api.easypost.com/v2/parcels?after_id=#{updated_since}&page_size=30")
        next_updated_since = response.last['id'] unless response.blank?
        {
          events: response.reverse,
          next_page: next_updated_since
        }
      },
     
			output_fields: ->(object_definitions) {
        object_definitions['parcel']
      }
    },
     
  },
  pick_lists: {
    eel_pfc: ->(connection) {
      [
      ["eel","NOEEI 30.37(a)"],
      ["pfc","pfc"]
      ]
    },
    contents_type: ->(connection) {
      [
        ["documents","documents"],
        ["gift","gift"],
        ["merchandise","merchandise"],
      	["return_goods","return_goods"],
      	["sample","sample"],
        ["others","others"]
        ]
      },
    non_delivery_option: ->(connection) {
      [
        ["Work","Work"],
        ["Home","Home"],
        ["Mobile","Mobile"],
        ["Fax","Fax"],
        ["Direct","Direct"],
        ]
      },
    restriction_type: ->(connection) {
      [
        ["Work","Work"],
        ["Home","Home"],
      ]
    },
	}
}
