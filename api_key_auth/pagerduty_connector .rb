{
  title: 'PagerDuty',
   connection: {
    fields: [
      { 
        name: 'api_key', 
        control_type: 'password' 
      },
      { 
        name: 'From', 
        hint: 'The user email who makes the request' 
      }
    ],

    authorization: {
      type: 'api_key',

      credentials: ->(connection) {
        headers("Authorization": "Token token=#{connection['api_key']}",
                'Accept': "application/vnd.pagerduty+json;version=2",
                'From': connection['From'])
      }
    }
  },

  test: ->(connection) {
    get("https://api.pagerduty.com/log_entries")
  },
  
  object_definitions: {
    incident: {
      fields: ->() {
        [
          { name:'id' },
          { name: 'type' },
          { name: 'summary' },
          { name: 'self', control_type: :url },
          { name: 'html_url',control_tyoe: :url },
          { name: 'incident_number', type: :integer },
          { name: 'created_at' },
          { name: 'status' },
          { name: 'incident_key' },
          { name: 'service', type: :array, of: :object, properties: [
            { name: 'id' },
            { name: 'type' },
            { name: 'summary' },
            { name: 'self', control_type: :url },
            { name: 'html_url', control_type: :url }
          ]},
          { name: 'last_status_change_at' },
          { name: 'last_status_change_by', type: :array, of: :object, properties: [
            { name: 'id' },
            { name: 'type' },
            { name: 'summary' },
            { name: 'self', control_type: :url },
            { name: 'html_url', control_type: :url }
          ]},
          { name: 'escalation_policy', type: :array, of: :object, properties: [
            { name: 'id' },
            { name: 'type' },
            { name: 'summary' },
            { name: 'self', control_type: :url },
            { name: 'html_url', control_type: :url }
          ]},
          { name: 'teams', type: :array, of: :object, properties: [
            { name: 'id' },
            { name: 'type' },
            { name: 'summary' },
            { name: 'self', control_type: :url },
            { name: 'html_url', control_type: :url }
          ]},
          { name: 'importance' },
          { name: 'urgency' }
        ]
      }
    },

    log_entries: {
      fields: ->() {
        [
          { name: 'id' },
          { name: 'type' },
          { name: 'summary' },
          { name: 'self', control_type: :url },
          { name: 'html_url', control_type: :url },
          { name: 'created_at' },
          { name: 'agent', type: :array, of: :object, properties: [
            { name: 'id' },
            { name: 'type' },
            { name: 'summary' },
            { name: 'self', control_type: :url },
            { name: 'html_url', control_type: :url }
          ]},
          { name: 'channel' },
          { name: ';acknowledgement_timeout' },
          { name: 'service', type: :array, of: :object, properties: [
            { name: 'id' },
            { name: 'type' },
            { name: 'summary' },
            { name: 'self', control_type: :url },
            { name: 'html_url', control_type: :url }
          ]},
          { name: 'incident', type: :array, of: :object, properties: [
            { name: 'id' },
            { name: 'type' },
            { name: 'summary' },
            { name: 'self', control_type: :url },
            { name: 'html_url', control_type: :url }
          ]},
          { name: 'teams', type: :array, of: :object, properties: [
            { name: 'id' },
            { name: 'type' },
            { name: 'summary' },
            { name: 'self', control_type: :url },
            { name: 'html_url', control_type: :url }
          ]}
        ]
      }
    }
  },

  actions: {
    get_incident_by_ID: {
      description: 'Get <span class="provider">incident by ID </span> in <span class="provider">PagerDuty</span>',
       
      input_fields: ->(object_definitions) {
        object_definitions['incident'].required('id').only('id')
      },
       
      execute: ->(connection, input) {
        get("https://api.pagerduty.com/incidents/#{input['id']}")
      },
       
      output_fields: ->(object_definitions) {
        [
          { name: 'incident', type: :object, properties: object_definitions['incident'] }
        ]
      }
    },
    
    list_log_entries: {
      description: 'List <span class="provider">Log Entries </span> in <span class="provider">PagerDuty</span>',

      input_fields: ->() {
        [
          { name: 'time_zone' },
          { name: 'since', hint: 'start of the date range' },
          { name: 'until', hint: 'end of the date range' },
          { name: 'is_overview', type: :boolean, hint: 'true will return a subset of log entries that shows most important changes' },
          { name: 'include', hint: 'additional details' }
        ]
      },
       
      execute: ->(connection, input) {
        get("https://api.pagerduty.com/log_entries",input)
      },
       
      output_fields: ->(object_definitions) {
        [
          { name: 'log_entries', type: :array, of: :object, properties: object_definitions['log_entries'] }
        ]
      }
    },
    
    update_incident: {
      description: 'Update <span class="provider">Incident </span> in <span class="provider">PagerDuty</span>',

      input_fields: ->() {
        [
          { name: 'id', hint: 'ID of the incident', optional: false },
          { name: 'type', optional: false, control_type: 'select', pick_list: 'type' },
          { name: 'status', control_type: 'select', pick_list: 'status' },
        ]
      },

      execute: ->(connection, input) {
        hash = {
          "incident" => {
            'type'=>input['type'],
            'status'=>input['status']
          }
        }

        put("https://api.pagerduty.com/incidents/#{input.delete('id')}", hash)
      },

      output_fields: ->(object_definitions) {
        [
          { name: 'incident', type: :object, properties: object_definitions['incident'] }
        ]
      }
    },
     
    search_incident: {
      description: 'Search <span class="provider">Incident</span> in <span class="provider">PagerDuty</span>',
       
      input_fields: ->() {
        [
          { name: 'since', hint: 'Start of the date range' },
          { name: 'until', hint: 'End of the date range' },
          { name: 'incident_key' },
          { name: 'status', control_type: 'select', pick_list: 'status' },
          { name: 'urgency', control_type: 'select', pick_list: 'urgency' },
          { name: 'time_zone' }
        ]
      },
       
      execute: ->(connection, input) {
        get("https://api.pagerduty.com/incidents", input)
      },
       
      output_fields: ->(object_definitions) {
        [
          { name: 'incidents', type: :array, of: :object, properties: object_definitions['incident'] }
        ]
      }
    }
  },

  triggers: {
    new_incident: {
      description: 'New <span class="provider">Incident</span> in <span class="provider">PagerDuty</span>',
      
      type: :paging_desc,
      
      input_fields: ->() {
        [
          { name: 'since', type: :timestamp }
        ]
       },
      
      poll: ->(connection,input,last_created_since) {
        since = (last_created_since||input['since'] || Time.now)

        response = get("https://api.pagerduty.com/incidents?since=#{since}&sort_by=created_at:DESC")

        last_created_since = response['incidents'].last['created_at'] unless response.blank?

        {
          events: response['incidents'],
          next_page: response['limit'] >= 100 ? last_created_since : nil
        }
      },
      
      dedup: ->(incident) {
        incident['id']
      },
      
      output_fields: ->(object_definitions) {
        object_definitions['incident']
      }
    }
  },

  pick_lists: {
    status: ->() {
      [
        ['Triggered', 'triggered']
        ['Acknowledged', 'acknowledged']
        ['Resolved', 'resolved']
      ]
    },

    urgency: ->() {
      [
        ['High', 'high'],
        ['Low', 'low']
      ]
    },

    type: ->() {
      [
        ["Incident", "incident"],
        ["Incident Reference", "incdient_reference"]
      ]
    }
  }
}
