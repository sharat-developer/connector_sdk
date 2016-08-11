{
  title: 'Librato',

  # HTTP basic auth example.
  connection: {
    fields: [
      {
        name: 'username',
        optional: false,
        hint: 'Your username; leave empty if using API key below'
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

      # Provide a preview user to display in the recipe data tree.
      preview: ->(connection) {
        get("https://metrics-api.librato.com/v1/alerts")
      },

      # Field definition.  The arguments available to use here are:
      # - The connection data (same as in the authorization hooks above), and
      # - The fields derived from preview/example object, if "preview" is defined above.

      # One example: Purely static field definition - no need to bind these arguments
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

      # Another - sometimes the easiest one to get started with: Just use the field definitions
      # as we interpreted them from the preview object.
      # fields: ->(connection, preview_fields) {
      #   preview_fields
      # }

      # This example uses an API's metadata endpoing to produce the field definitions.  In this
      # example we don't use the preview-derived fields, so we don't even have to bind them.
      #
      # (implementation note: if preview fields are not bound we can skip the conversion)
      # fields: ->(connection) {
      #   get("https://#{connection['subdomain']}.freshdesk.com/api/user_fields.json").
      #     map { |field| field.slice('name', 'type') }
      # }
    },
    
    #v2 format
    new_alert: {
       fields: ->(connection) {
       	[
          { name: 'id' },
        	{ name: 'name'},
          { name: 'description'},
          { name: 'conditions', type: :object, properties: [
            { name: 'id'},
            { name: 'type'},
            { name: 'metric_name'},
            { name: 'source'},
            { name: 'threshold'},
            { name: 'duration'},
            { name: 'summary_function'}
           ]},
          { name: 'services', type: :object, properties: [
            { name: 'id'},
            { name: 'type'},
            { name: 'settings', type: :object, properties: [
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
          { name: 'version'}
        ]
       }  
    },
    
    metric: {
#     	name	Each metric has a name that is unique to its class of metrics e.g. a gauge name must be unique amongst gauges. The name identifies a metric in subsequent API calls to store/query individual measurements and can be up to 255 characters in length. Valid characters for metric names are ‘A-Za-z0-9.:-_’. The metric namespace is case insensitive.
# period	The period of a metric is an integer value that describes (in seconds) the standard reporting period of the metric. Setting the period enables Metrics to detect abnormal interruptions in reporting and aids in analytics.
# description	The description of a metric is a string and may contain spaces. The description can be used to explain precisely what a metric is measuring, but is not required. This attribute is not currently exposed in the Librato UI.
# display_name	More descriptive name of the metric which will be used in views on the Metrics website. Allows more characters than the metric name, including spaces, parentheses, colons and more.
# attributes	The attributes hash configures specific components of a metric’s visualization.
  		 # Provide a preview user to display in the recipe data tree.
      preview: ->(connection) {
        get("https://metrics-api.librato.com/v1/metrics")
      },

      # Field definition.  The arguments available to use here are:
      # - The connection data (same as in the authorization hooks above), and
      # - The fields derived from preview/example object, if "preview" is defined above.

      # One example: Purely static field definition - no need to bind these arguments
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
          #'alert': get("https://metrics-api.librato.com/v1/alerts?version=#{['version']}&name=#{['name']}}", input)
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
    update_alerts: {
#             curl \
#         -u <user>:<token> \
#         -X PUT \
#         -H "Content-Type: application/json" \
#         -d '{"active": false, "name": "my.alert.name", "description": "Process went down", "conditions": [{"type": "absent", "metric_name": "service.alive", "source": "*", "duration": 900}]}' \
#       "https://metrics-api.librato.com/v1/alerts/123"
      
        input_fields: ->(object_definitions) {
        # Assuming here that the API only allows searching by these terms.
        object_definitions['alert']
        
      },

      execute: ->(connection, input) {
        {
          #'alert': get("https://metrics-api.librato.com/v1/alerts?version=#{['version']}&name=#{['name']}}", input)
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
    search_metrics: {
    	input_fields: ->(object_definitions){
        object_definitions['metric'].only('name')
      },
      #https://metrics-api.librato.com/v1/metrics  
      execute: ->(connection, input) {
        {
          #'alert': get("https://metrics-api.librato.com/v1/alerts?version=#{['version']}&name=#{['name']}}", input)
          'metric': get("https://metrics-api.librato.com/v1/metrics?name=#{['name']}", input)
        }
      },

      output_fields: ->(object_definitions) {
        [
          {
            name: 'metric',
            type: :array,
            of: :object,
            properties: object_definitions['metric']
          }
        ]
      }
    }
  },

  triggers: {

    new_alert: {

      input_fields: ->() {
        [
          {
            name: 'since',
            type: :timestamp,
            hint: 'Defaults to Alerts created after the recipe is first started'
          }
        ]
      },

      poll: ->(connection, input, last_updated_since) {
        
        input['since'].present? ? (input['since'] = input['since'].to_time.to_f) : input['since']

        updated_since = last_updated_since || input['since'].to_f || (Time.now).to_f

        alerts = get("https://metrics-api.librato.com/v1/alerts?version=2").
                  params( length: '3', # Small page size to help with testing.
                          orderby: 'updated_at', # Because we can only query by updated_since in this API.
                          sort: 'asc')['alerts']

          next_updated_since = alerts.last['updated_at'] unless alerts.blank? 
        puts (next_updated_since)
        puts (updated_since)
        puts "cond 1 : " + (next_updated_since.to_f > updated_since.to_f).to_s
        puts "cond 2 : " + (alerts.length >= 2).to_s
        puts "cond 3 : " + (alerts.blank? ? "false" : "true")
        puts ((next_updated_since > updated_since) or (alerts.length >= 2) or (alerts.blank? ? false : true))
        # Return three items:
        # - The polled objects/events (default: empty/nil if nothing found)
        # - Any data needed for the next poll (default: nil, uses one from previous poll if available)
        # - Flag on whether more objects/events may be immediately available (default: false)
        {
          events: alerts,
          next_poll: next_updated_since,
          # common heuristic when no explicit next_page available in response: full page means maybe more.
          #can_poll_more: alerts.length >= 3
          can_poll_more: ((next_updated_since > updated_since) or (alerts.length >= 2) or (alerts.blank? ? false : true))
          #can_poll_more: if next_updated_since < updated_since then false else alerts.length <= 2 unless alerts.blank?
        }
      },

      dedup: ->(alert) {
        alert['id'].to_s + "@" + alert['updated_at'].to_s
      },

      output_fields: ->(object_definitions) {
        object_definitions['new_alert']
      }
    },
    track_alert_status: {
      
      input_fields: ->() {
        [ {
          	name: 'AlertID',
          	type: :integer,
          	hint: 'insert the Alert\'s ID that you would like to track'
          } ]
      },

      poll: ->(connection, input, last_updated_since) {
        updated_since = last_updated_since || input['since'] || Time.now

				status = get("https://metrics-api.librato.com/v1/alerts/#{input['AlertID']}/status")['status']
				#alert = get("https://metrics-api.librato.com/v1/alerts/#{input['AlertID']}")['alert']
        puts(status)
#                           updated_since: updated_since.to_time.utc.iso8601)['alerts']

        #next_updated_since = unless alerts.blank? then alerts.last else Time.now
          next_updated_since = # status.last['created_at'] unless status.blank? 
        #next_updated_since = updated_since: updated_since.to_time.utc.iso8601)

        # Return three items:
        # - The polled objects/events (default: empty/nil if nothing found)
        # - Any data needed for the next poll (default: nil, uses one from previous poll if available)
        # - Flag on whether more objects/events may be immediately available (default: false)
        {
          events: status,
          next_poll: next_updated_since,
          # common heuristic when no explicit next_page available in response: full page means maybe more.
          can_poll_more: false#status.length >= 3
          #can_poll_more: if next_updated_since < updated_since then false else alerts.length <= 2 unless alerts.blank?
        }
      },

#       dedup: ->(status) {
#         status['id']
#       },

      output_fields: ->(object_definitions) {
				[
          {name: 'status'}
         ]
      }
    }
    

  }
}



