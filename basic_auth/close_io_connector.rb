{
  title: 'Close.io',

  connection: {
    fields: [
      {
        name: 'api_key',
        optional: false,
        hint: 'Profile (top right) > Settings > Your API Keys'
      }
    ],

    authorization: {
      type: 'basic_auth',
      
      # close.io uses api key only for authentication. treats apikey as username and password left blank
      # "https://app.close.io/api/v1/me/" -u {api_key}: 
      credentials: ->(connection) {
        user(connection['api_key'])
        password("")
      }
    }
  },

  object_definitions: {
    lead: {
      fields: ->() {
        [
          { name: 'name' },
          { name: 'display_name' },
          { name: 'id' },
          { name: 'status_id' },
          { name: 'date_updated' },
          { name: 'status_label' },
          { name: 'description' },
          { name: 'html_url' },
          { name: 'created_by' },
          { name: 'organization_id' },
          { name: 'url' },
          { name: 'updated_by' },
          { name: 'created_by_name' },
          { name: 'date_created' },
          { name: 'updated_by_name' }
        ]
      }
    }
  },

  test: ->(connection) {
    get("https://app.close.io/api/v1/me/")
  },

  actions: {
    
    get_lead_by_id: {
      input_fields: ->() {
        [
          { name: "lead_id", optional: false }
        ]
      },
      execute: ->(connection, input) {
        get("https://app.close.io/api/v1/lead/#{input['lead_id']}/")
      },
      output_fields: ->(object_definitions) {
        object_definitions['lead']
      }
    }
  },

  triggers: {

    new_lead: {

      input_fields: ->() {
        [
          {
            name: 'since',
            type: :date,
            hint: 'Defaults to leads created after the recipe is first started'
          }
        ]
      },

      poll: ->(connection, input, skip_size) {
        skip_size = skip_size || 0
        since = (input['since'] || Time.now).to_date
        
        results = get("https://app.close.io/api/v1/lead/").
                  params(query: "created > #{since}",
                         _limit: 2,
                         _skip: skip_size)
        
        leads = results['data']

        next_skip_size = results['has_more'] ? (skip_size + leads.length) : 0

        {
          events: leads,
          next_poll: next_skip_size,
          can_poll_more: results['has_more']
        }
      },

      dedup: ->(lead) {
        lead['id']
      },

      output_fields: ->(object_definitions) {
        object_definitions['lead']
      }
    }
  }
}
