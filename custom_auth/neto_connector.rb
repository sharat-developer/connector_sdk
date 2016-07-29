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
          { name: 'DateUpdated' }
        ]
      }
    }
  },

  test: ->(connection) {
    post("https://#{connection['domain']}.neto.com.au/do/WS/NetoAPI").headers('NETOAPI_ACTION': 'GetCustomer')
  },

  actions: {
    get_users: {
      input_fields: ->(object_definitions) {
        
      },

      execute: ->(connection, input) {
        payload = {
          "filter" => {
            "DateUpdatedFrom" => (Time.now - 1.days).utc.strftime("%F %T"),
            "Page" => 0,
            "Limit" => 10
          },
          "OutputSelector" => ["Username","ID"]
        }
        
        post("https://#{connection['domain']}.neto.com.au/do/WS/NetoAPI", payload).headers('NETOAPI_ACTION': 'GetCustomer')
      },

      output_fields: ->(object_definitions) {
        object_definitions['customer']
      }
    }
  },

  triggers: {

    updated_customer: {
      description: 'Updated <span class="provider">customer</span> in <span class="provider">Neto</span>',

      input_fields: ->() {
        [
          {
            name: 'since',
            type: :timestamp,
            hint: 'Defaults to customer updated after the recipe is first started'
          }
        ]
      },

      poll: ->(connection, input, page) {
        page ||= 0
        limit = 10
        updated_since = input['since'] || Time.now
        
        payload = {
          "filter" => {
            "DateUpdatedFrom" => (updated_since).utc.strftime("%F %T"),
            "Page" => page,
            "Limit" => limit,
            "OutputSelector" => ["Username", "ID", "EmailAddress", "DateUpdated"]
          },
        }

        customers = post("https://#{connection['domain']}.neto.com.au/do/WS/NetoAPI", payload).
                      headers('NETOAPI_ACTION': 'GetCustomer')['Customer']

        {
          events: customers,
          next_poll: ((page + 1) unless customers.length < limit),
          can_poll_more: customers.length == limit
        }
      },
			
      document_id: ->(customer) {
        customer['ID']
      },
      
      sort_by: ->(customer) {
        customer['DateUpdated']
      },

      output_fields: ->(object_definitions) {
        object_definitions['customer']
      }
    }
  }
}
