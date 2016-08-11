{
  title: 'Pagerduty',
   connection: {
    fields: [
      { 
        name: 'domain', 
        control_type: 'subdomain', 
        url: 'pagerduty.com' 
       },
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
          'From': "#{connection['From']}")
      }
    }
  },

  test: ->(connection) {
    get("https://api.pagerduty.com/log_entries")
  },
  
  object_definitions: {
    incident:{
      fields:->() {
        [
          {name: 'incident', type: :object,propertioes: [
            {name: 'id',hint: 'Id of the incident'},
            {name: 'type', control_type: 'select', picklist: [['incidient'], ['incident_reference']]},
            {name: 'status',control_type: 'select', picklist: [['resolved'], ['acknowledged']]},
            {name: 'escalation_level',type: :integer},
            {name: 'assignments',},
            {name: 'assignee', },
            {name: 'UserReference', type: :object, properties: [ 
              {name: 'id'},
              {name: 'summary'},
              {name: 'type', hint: 'user or user_reference'},
              ]},
            ]
           },
          ]
        },
      },    
             
    log_entries: {
      fields:->() {
        [
          {name: 'time_zone'},
          {name: 'since',hint: 'start of the date range'},
          {name: 'until', hint: 'end of the date range'},
          {name: 'is_overview',type: :boolean,hint: 'true will return a subset of log entries that shows most important changes'},
          {name: 'include', hint: 'additional details'},
         ]
        }
      }
    },

  actions: {
    get_incident_by_ID: {
      description: 'Search <span class="provider">incident by ID </span> in <span class="provider">PageDuty</span>',
      input_fields: ->(object_definitions) {
        object_definitions['incident'].required('id').only('id')
      },
      execute: ->(connection, input) {
        get("https://api.pagerduty.com/incidents/#{input['id']}")
      },
      output_fields: ->(object_definitions) {
        object_definitions['incident']
      }
     },
    
    list_log_entries: {
      description: 'List <span class="provider">log entries </span> in <span class="provider">PageDuty</span>',
      input_fields: ->(object_definitions) {
        object_definitions['log_entries']
      },
      execute: ->(connection, input) {
        get("https://api.pagerduty.com/log_entries",input)
      },
      output_fields: ->(object_definitions) {
        object_definitions['log_entries']
      }
     },
    
     update_incident: {
      description: 'Update <span class="provider">incident</span> in <span class="provider">pagerduty</span>',
      input_fields: ->(object_definitions) {
        object_definitions['incident'].required('id','type')
      },
      execute: ->(connection, input) {     
        id=input['incident'].delete("id")
        put("https://api.pagerduty.com/incidents/#{id}",input)
       },
      output_fields: ->(object_definitions) {
        object_definitions['incident']
      }
    },
   },

  triggers: {
		new_incident: {
      
      type: :paging_desc,
      
      input_fields: ->() {
        [
          { name: 'since', type: :timestamp }
        ]
      },
      
      poll: ->(connection,input,page) {
        page ||= 0
        since = (input['since'] || Time.now)
        
        response = get("https://api.pagerduty.com/incidents?since=#{since}").params(offset: page)
        {
          events: response['incidents'],
          next_page: response['total'] != 0 ? response['offset'] : nil
        }
      },
        document_id: ->(incident) {
        incident['id']
      },
   
           sort_by: ->(incident) {
        incident['created_at']
      },
      
      output_fields: ->(object_definitions) {
        object_definitions['incident']
        }
    }
  },

  pick_lists: {

  }
}
