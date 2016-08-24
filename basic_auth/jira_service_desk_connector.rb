{
title: 'JIRA Service Desk',

  connection: {
    fields: [
      {
        name: 'subdomain',
        control_type: 'subdomain',
        url: '.atlassian.net',
        optional: false,
        hint: 'Your jira Service Desk name as found in your JIRA Service Desk URL'
      },
      {
        name: 'username',
        optional: false,
        hint: 'JIRA Username or Email'
      },
      {
        name: 'password',
        control_type: 'password',
        optional: false
      }
    ],

    authorization: {
      type: 'basic_auth',

      credentials: ->(connection) {
        user(connection['username'])
        password(connection['password'])
      }
    }
  },

  test: ->(connection) {
    get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request")
  },

  object_definitions: {

    request: {
      fields: ->(connection, config) {
        [
          { name:'issueId', type: :integer },
          { name:'issueKey' },
          {
            name: 'serviceDeskId', label: 'ServiceDesk',
            control_type: 'select', pick_list: 'service_desk'
          },
          {
            name: 'requestTypeId', Label: 'Request Type',
            control_type: 'select', pick_list: 'request_type',
            pick_list_params: { serviceDeskId: 'serviceDeskId' }
          },
          { name:'reporter', type: :object, properties: [
            { name: 'name' },
            { name: 'key' },
            { name: 'emailAddress' },
            { name: 'displayName' },
            { name: 'timeZone' }
          ]},
          { name:'currentStatus', type: :object, properties: [
            { name: 'status' }
          ]},
          { name: '_links' , type: :object, properties: [
            { name: 'jiraRest' },
            { name: 'web' },
            { name: 'self'}
          ]},
          {
            name: 'requestFieldValues', optional: false, type: :object, properties:
              get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/servicedesk/#{config['serviceDeskId']}/requesttype/#{config['requestTypeId']}/field")['requestTypeFields'].map do |field|
                if field['validValues'].present?
                valid_values = field['validValues'].pluck('value', 'label').
                                                    map { |value| value[0].to_s + " (" + value[1].to_s + ")" }.
                                                    join(",<br>")

                hint = "Valid values are:<br>" + valid_values
              end

                {
                  name: field['fieldId'],
                  label: field['name'],
                  optional: field['required'] == false,
                  hint: hint
                }
              end || []
          }
        ]
      }
    },
       
    comment: {
      fields: ->() {
        [
          { name: 'id' },
          { name: 'body', control_type: 'text-area' },
          { name: 'public', type: :boolean },
          { name: "author",type: :object, properties: [ 
             { name: "name" },
             { name: "key" },
             { name: "emailAddress" },
             { name: "displayName" },
             { name: 'active',type: :boolean },
             { name: "timeZone" },
            { name: "_links", type: :object, properties: [ 
              { name: "jiraRest", type: :url },
              { name: "avatarUrls", type: :object, properties:[
                { name: "48x48" },
                {  name: "24x24" },
                { name: "16x16" },
                { name: "32x32" }
              ]},
              { name: "self" },
            ]},
          ]},
          { name: "created",type: :array, properties: [
            { name: "iso8601" },
            { name: "jira" },
            { name: "friendly" },
            { name: "epochMillis" }
          ]},
          { name: "_links", type: :object, properties: [ 
            { name: "self" },
          ]},
        ]
      }
    }
  },

  actions: {
    search_customer_request: {

      description: 'Search <span class="provider">Customer Request</span> in <span class="provider">JIRA Service Desk</span>',

      input_fields: ->(object_definitions) {
        object_definitions['request'].only('serviceDeskId', 'requestTypeId').
        concat([
          { name: 'searchTerm', hint: 'Enter the keyword for the request', optional: false },
          { name: 'requestStatus', control_type: 'select', pick_list: 'request_status' },
          { name: 'requestOwnership', control_type: 'select', pick_list: 'request_ownership'},
          { name: 'start' , hint: 'The starting index of the returned objects', type: :integer},
          { name: 'limit', hint: 'The maximum number of items to return per page', type: :integer}
        ])
      },

      execute: ->(connection, input) {
        get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request", input)
      },

      output_fields: ->(object_definitions) {
        [
          { name: 'values', type: :array, of: :object, properties: object_definitions['request'] }
        ]
      },

      sample_output: ->(connection) {
        get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request") || []
      }
    },

    create_customer_request: {

      description: 'Create <span class="provider">Customer Request</span> in <span class="provider">JIRA Service Desk</span>',

      config_fields: [
        {
          name: 'serviceDeskId', label: 'Service Desk', optional: false,
          control_type: 'select', pick_list: 'service_desk'
        },
        {
          name: 'requestTypeId', label: 'Request Type', optional: false,
          control_type: 'select', pick_list: 'request_type',
          pick_list_params: { serviceDeskId: 'serviceDeskId' }
        }
      ],

      input_fields: ->(schema) {
        schema['request'].only('requestFieldValues')
      },
    
      execute: ->(connection, input) {
        response = post("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request", input)

        response['requestFieldValues'] = response['requestFieldValues'].map do |field|
                                           { field['fieldId'] => field['value'] }
                                         end.inject(:merge)

        response
      },
    
      output_fields: ->(object_definitions) {
        object_definitions['request']
      },
      
      sample_output: ->(connection) {
        get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request")['values'].first || {}
      }
    },
    
    create_comment: {
      description: 'Create <span class="provider">Comment</span> in <span class="provider">JIRA Service Desk</span>',

      input_fields: ->() {
        [
          { name: 'Issue', hint: 'Issue Id or Issue Key', optional: false },
          { name: 'body', optional: false },
          { name: 'public', type: :boolean, optional: false}
        ]
      },

      execute: ->(connection, input) {
        post("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request/#{input.delete('Issue')}/comment", input)
      },

      output_fields: ->(object_definitions) {
        object_definitions['comment']
      },
      
      sample_output: ->(connection) {
        issueId = get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request")['values'].first['issueId']
        commentId = get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request/#{issueId}/comment")['values'].first['id']
        get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request/#{issueId}/comment/#{commentId}")
      },
    },

    get_comment_by_ID: {
      
      description: 'Get <span class="provider">Comment</span> by ID in <span class="provider">JIRA Service Desk</span>',

      input_fields: ->() {
        [
          { name: 'Issue', hint: 'Issue Id or Issue Key', optional: false },
          { name: 'commentId', optional: false},
        ]
      },

      execute: ->(connection, input) {
        get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request/#{input['Issue']}/comment/#{input['commentId']}")
      },

      output_fields: ->(object_definitions) {
        object_definitions['comment']
      },
      
      sample_output: ->(connection) {
        issueId = get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request")['values'].first['issueId']
        commentId = get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request/#{issueId}/comment")['values'].first['id']
        get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request/#{issueId}/comment/#{commentId}")
      },
    }
  },
  
  pick_lists: {
    
    service_desk: ->(connection) {
      get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/servicedesk")['values'].map do |desk|
        [desk['projectName'] , desk['id']]
      end
    },
    
    request_type: ->(connection, serviceDeskId:) {
      url = "https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/servicedesk/#{serviceDeskId}/requesttype"
      get(url)['values'].map do |type|
        [type['name'] , type['id']]
      end
    },
     
    request_status: ->(connection) {
      [
        ["Closed requests", "CLOSED_REQUESTS"],
        ["Open requests", "OPEN_REQUESTS"],
        ["All requests", "ALL_REQUESTS"]
      ]
    },
    
    request_ownership: ->(connection) {
      [
        ["Owned requests" , "OWNED_REQUESTS"],
        ["Participated requests" , "PARTICIPATED_REQUESTS"],
        ["All requests" , "ALL_REQUESTS"]
      ]
    },
  }
}
