{
  title: 'Unbounce',

  connection: {
    fields: [
      {
        name: 'api_key',
        optional: false,
        control_type: 'password',
        hint: 'Profile (top right) > Manage Account > API Keys'
      },
      {
        name: 'page_id',
        optional: false,
        hint: "ID of page to connect, found at the end of respective page's URL"
      }
    ],

    authorization: {
      type: 'basic_auth',
      # unbounce uses api key only for authentication. treats apikey as username and password left blank
      # curl -u "{your api_key}:" "https://api.unbounce.com"
      credentials: ->(connection) {
        user(connection['api_key'])
        password("")
      }
    }
  },

  test: ->(connection) {
    get("https://api.unbounce.com/pages/#{connection['page_id']}")
  },
  
  object_definitions: {
    form: {
      fields: ->(connection) {
        get("https://api.unbounce.com/pages/#{connection['page_id']}/form_fields")['formFields'].
          map { |field| { name: field['id'] } }
      }
    }
  },
  
  triggers: {
    new_submission: {
      
      type: :paging_desc,
      
      input_fields: ->() {
        [
          { name: 'since', type: :timestamp,
            hint: 'Defaults to submissions after the recipe is first started' }
        ]
      },

      poll: ->(connection, input, last_created_since) {
        since = last_created_since || input['since'] || Time.now
        
        leads = get("https://api.unbounce.com/pages/#{connection['page_id']}/leads").
                  params(from: since.to_time.iso8601,
                         sort_order: :desc, # API sorts by creation date
                         limit: 10)['leads']

        next_updated_since = leads.first['createdAt'] unless leads.length == 0

        {
          events: leads,
          next_page: next_updated_since
        }
      },

      output_fields: ->(object_definitions) {
        [
          { name: 'leads', type: :array, of: :object, properties: [
            { name: 'id', type: :integer },
            { name: 'form_data', type: :array, of: :object, properties: object_definitions['form'] }
          ]}
        ]
      }
    }
  }
}
