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

      poll: ->(connection, input, page) {
        page ||= 0
        limit = 50
        updated_since = input['since'] || Time.now
        
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

        {
          events: customers,
          next_poll: (page + 1),
          can_poll_more: customers.length == limit
        }
      },
			
      dedup: ->(customer) {
        customer['ID'] + "@" + customer['DateUpdated']
      },

      output_fields: ->(object_definitions) {
        object_definitions['customer']
      }
    }
  }
}
