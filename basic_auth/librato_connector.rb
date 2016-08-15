{
  title: 'Librato',

  connection: {
    fields: [
      {
        name: 'username',
        optional: false,
        hint: 'Your username'
      },
      {
        name: 'password',
        control_type: 'password',
        label: 'Password or personal API key'
      }
    ],

    authorization: {
      type: 'basic_auth',

      credentials: ->(connection) {
        if connection['username'].blank?
          user(connection['password'])
        else
          user(connection['username'])
          password(connection['password'])
        end
      }
    }
  },

  test: ->(connection) {
    get("https://metrics-api.librato.com/v1/metrics")
  },

  object_definitions: {

    #v1 format
    alert: {
      preview: ->(connection) {
        get("https://metrics-api.librato.com/v1/alerts")
      },

      fields: ->() {
        [
          { name: 'id',
            type: :integer 	},
					{	name: 'status'	},
          { name: 'name'		},
          { name: 'version'	},
          {	name: 'services'},
          { name: 'conditions' },
          { name: 'attributes' },
          { name: 'rearm_seconds'},
          { name: 'active' },
          { name: 'description' }
        ]
      },
    },
    
    #v2 format
    new_alert: {
      preview: ->(connection) {
        get("https://metrics-api.librato.com/v1/alerts")
      },
      
      fields: ->(connection) {
       	[
          { name: 'id' },
        	{ name: 'name'},
          { name: 'description'},
          { name: 'conditions', type: :array, of: :object, properties: [
            { name: 'id'},
            { name: 'type'},
            { name: 'metric_name'},
            { name: 'source'},
            { name: 'threshold'},
            { name: 'duration'},
            { name: 'summary_function'}
           ]},
          { name: 'services', type: :array, of: :object, properties: [
            { name: 'id'},
            { name: 'type'},
            { name: 'settings', type: :array, of: :object, properties: [
              { name: 'url'}
              ]},
            { name: 'title'},
            { name: 'name'}
            ]},
          { name: 'attributes', type: :object, properties: [
            { name: 'runbook_url'}
            ]},
          { name: 'active'},
          { name: 'created_at', type: :integer},
          { name: 'updated_at', type: :integer},
          { name: 'version'},
          { name: 'rearm_seconds' },
          { name: 'rearm_per_signal' }
        ]
       }  
    },
    
    metric: {
      preview: ->(connection) {
        get("https://metrics-api.librato.com/v1/metrics")
      },

      fields: ->() {
        [
        	{name: 'name',
           hint: 'Valid characters for metric names are ‘A-Za-z0-9.:-_’. The metric namespace is case insensitive.'},
          {name: 'period',type: :integer},
          {name: 'description'},
          {name: 'display_name'},
          {name: 'attributes'}
         ]
      }
    }
  },

  actions: {
    search_alerts: {
      input_fields: ->(object_definitions) {
        # Assuming here that the API only allows searching by these terms.
        object_definitions['alert'].only('version','name')
        
      },

      execute: ->(connection, input) {
        {
          'alert': get("https://metrics-api.librato.com/v1/alerts", input)
        }
      },

      output_fields: ->(object_definitions) {
        [
          {
            name: 'alert',
            type: :array,
            of: :object,
            properties: object_definitions['alert']
          }
        ]
      }
    },
    
    update_alert: {
      
        input_fields: ->(object_definitions) {
        object_definitions['alert'].reject { |field| field[:name] == 'id' }
        
      },

      execute: ->(connection, input) {
        {
          'alert': put("https://metrics-api.librato.com/v1/alerts", input)
        }
      },

      output_fields: ->(object_definitions) {
        [
          {
            name: 'alert',
            type: :array,
            of: :object,
            properties: object_definitions['alert']
          }
        ]
      }
    },
    
    get_alert_by_id: {
      input_fields: ->(object_definitions){
        [{ name: 'id', optional: false}]
        },
      
      execute: ->(connection, input){
        get("https://metrics-api.librato.com/v1/alerts/#{input['id']}", input)
        },
      
      output_fields: ->(object_definitions){
          object_definitions['new_alert']
        }
    },
    
    search_metrics: {
    	input_fields: ->(object_definitions){
        object_definitions['metric'].only('name')
      },

      execute: ->(connection, input) {
        {
          'metrics': get("https://metrics-api.librato.com/v1/metrics?name=#{['name']}", input)['metrics'] 
        }
      },

      output_fields: ->(object_definitions) {
        [
          {
            name: 'metrics', type: :array, of: :object, properties: object_definitions['metric']
          }
        ]
      }
    }
  },

  triggers: {
    
    triggered_alerts: {
      
      input_fields: ->(connection) {},
      poll: ->(connection, input, page) {
        
        statuses = get("https://metrics-api.librato.com/v1/alerts/status")['firing']
        
        next_created_since = statuses.first['triggered_at'] unless statuses.blank?
        {
          events: statuses,
          next_page: next_created_since
         }
      },
      
      sort_by: ->(status) {
        status['triggered_at']
      },
      
      dedup: ->(status) {
        [status['id'].to_s, status['triggered_at'].to_s].join("_")
      },
      output_fields: ->(object_definitions){
         [{name: 'id'}, {name: 'triggered_at'}]
        }
      
    }
  }
}



