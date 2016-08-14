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
          'From': connection['From'])
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
          {name:'id'},
          {name: 'type'},
          {name: 'summary'},
          {name: 'self', control_type: :url},
          {name: 'html_url',control_tyoe: :url},
          {name: 'incident_number', type: :integer},
          {name: 'created_at'},
          {name: 'status'},
          {name: 'incident_key'},
          {name: 'service',type: :array, of: :object, properties: [
            {name: 'id'},
            {name: 'type'},
            {name: 'summary'},
            {name: 'self', control_type: :url},
            {name: 'html_url',control_type: :url}
           ]},
          {name: 'last_status_change_at'},
          {name: 'last_status_change_by', type: :array,of: :object, properties:[
            {name: 'id'},
            {name: 'type'},
            {name: 'summary'},
            {name: 'self', control_type: :url},
            {name: 'html_url',control_type: :url}
           ]},
          {name: 'escalation_policy', type: :array,of: :object, properties:[
            {name: 'id'},
            {name: 'type'},
            {name: 'summary'},
            {name: 'self', control_type: :url},
            {name: 'html_url',control_type: :url}
           ]},
          {name: 'teams',type: :array,of: :object, properties:[
            {name: 'id'},
            {name: 'type'},
            {name: 'summary'},
            {name: 'self', control_type: :url},
            {name: 'html_url',control_type: :url}
           ]},
          {name: 'importance'},
          {name: 'urgency'},
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
       description: 'Update <span class="provider">incident</span> in <span class="provider">PagerDuty</span>',
       input_fields: ->() {
         [
           {name: 'id',hint: 'Id of the incident',optional: false},
          {name: 'incident', type: :object,properties: [
            {name: 'type', control_type: 'select', pick_list: [['incidient'], ['incident_reference']], optional: false},
            {name: 'status',control_type: 'select', pick_list: [['resolved'], ['acknowledged']]},
            ]}
            
           ]
       },
       execute: ->(connection, input) {
         put("https://api.pagerduty.com/incidents/#{input.delete('id')}", input)
       },
       output_fields: ->(object_definitions) {
         object_definitions['incident']
       }
     },
     
     search_incident: {
       description: 'Search <span class="provider">incident by ID </span> in <span class="provider">PageDuty</span>',
       input_fields: ->(object_definitions) {
         object_definitions['incident'].only('id')
          [
           { name: 'since'},
            {name: 'until'},
            {name: 'incident_key'},
            {name: 'statuses[]', control_type: 'select', pick_list: [['resolved'], ['acknowledged']]},
            {name: 'urgencies[]'},
            {name: 'time_zone'},
            {name: 'sort_by'},
          ]
       },
       execute: ->(connection, input) {
         get("https://api.pagerduty.com/incidents", input)
       },
       text: ->(object_definitions) {
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
      
      poll: ->(connection,input,last_created_since) {
        since = (last_created_since||input['since'] || Time.now)
        
        response = get("https://api.pagerduty.com/incidents?since=#{since}")
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
    },
    
  },

}
