{
  title: 'Jira Service Desk',

  connection: {
    fields: [
      {
        name: 'subdomain',
        control_type: 'subdomain',
        url: '.atlassian.net',
       	optional: false
        hint: 'Your jira service desk name as found in your jira service desk URL'
      },
      {
        name: 'username',
        optional: false,
        hint: 'Your username or Email'
      },
      {
        name: 'password',
        control_type: 'password',
        label: 'Password'
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
      fields: ->() {
        [
          { name:'issueId', type: :integer },
          { name:'issueKey' },
          { name:'requestTypeId', type: :integer },
          { name:'serviceDeskId', type: :integer },
          { name:'reporter', type: :object, properties: [
            { name: 'name' },
            { name: 'key' },
            { name: 'emailAddress' },
            { name: 'displayName' },
            { name: 'timeZone' }
          ]},
          { name:'requestFieldValues', type: :array, of: :object, properties: [
            { name: 'fieldId' },
            { name: 'label' },
            { name: 'value' }
          ]},
          { name:'currentStatus', type: :object, properties:[
            { name: 'status' }
          ]}
        ]
      }
    },
       
    comment: {
 	fields: ->() {
  	[
      	  { name: 'id' },
          { name: 'body', control_type: 'text-area' },
          {name: "author",type: :array, properties: [ 
             {name: "name"},
             {name: "key"},
             {name: "emailAddress"},
             {name: "displayName"},
             {name: 'active',type: :boolean},
             {name: "timeZone"},
           ]},
          {name: "created",type: :array, properties: [
            {name: "iso8601"},
            {name: "jira"},
            {name: "friendly"},
            {name: "epochMillis"}
           ]},
        ]
      }
    }
  },

  actions: {

    search_customer_request: {

      description: 'Get <span class="provider">customer request</span> in <span class="provider">JIRA Service Desk</span>',
     
      input_fields: ->(object_definitions) {
        object_definitions['request'].only('serviceDeskId', 'requestTypeId').
        concat([
          { name: 'searchTerm', hint: 'Enter the keyword for the request', optional: false }
        ])
      },

      execute: ->(connection, input) {
        get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request", input)
      },

      output_fields: ->(object_definitions) {
        [
          { name: 'values', type: :array, of: :object, properties: object_definitions['request'] }
        ]
      }
    },

    create_customer_request: {
     
      description: 'Create <span class="provider">customer request</span> in <span class="provider">JIRA Service Desk</span>',

      input_fields: ->() {
        [
          {
            name: 'serviceDeskId', label: 'Service desk', type: :integer, optional: false,
            control_type: :select, pick_list: :service_desks
          },
          {
            name: 'requestTypeId', label: 'Request type', type: :integer, optional: false,
            control_type: :select, pick_list: :request_types,
            pick_list_params: { serviceDeskId: 'serviceDeskId' }
          },
          { name: 'requestFieldValues_summary', label: 'Summary', optional: false },
          { name: 'requestFieldValues_description', label: 'Description', optional: false }
        ]
      },
    
      execute: ->(connection, input) {
        hash = {
          "requestFieldValues"=> {
            'summary' => input['requestFieldValues_summary'],
            'description'=>input['requestFieldValues_description']
          },
          "serviceDeskId" => input['serviceDeskId'],
          "requestTypeId" => input['requestTypeId']
        }

        post("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request", hash)
       },
    
      output_fields: ->(object_definitions) {
        object_definitions['request']
      }
    },
    
    create_comment: {

      description: 'Create <span class="provider">comment</span> in <span class="provider">JIRA Service Desk</span>',

      input_fields: ->() {
        [
          { name: 'Id', hint: 'Issue ID or Issue Key', optional: false },
          { name: 'body' , optional: false },
          { name: 'public', hint: 'true or false', type: :boolean , optional: false }
        ]
      },

      execute: ->(connection, input) {
        t = input.reject { |k,v| k == 'Id' }

        post("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request/#{input['Id']}/comment", t)
      },

      output_fields: ->(object_definitions) {
        object_definitions['comment']
      }
    },
  
    get_comment_by_id: {
      
      description: 'Get <span class="provider">comment</span> by ID in <span class="provider">JIRA Service Desk</span>',

      input_fields: ->() {
        [
          { name: 'Id', hint: 'Issue ID or Issue Key', optional: false },
          { name: 'commentId', optional: false ,hint: 'Comment ID'},
        ]
      },

      execute: ->(connection, input) {
        get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request/#{input['Id']}/comment/#{input['commentId']}")
      },

      output_fields: ->(object_definitions) {
        object_definitions['comment']
      }
    }
  },

  pick_lists: {
    service_desks: ->(connection) {
      sds = get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/servicedesk")['values']
      (sds || []).map { |sd| [sd['projectName'], sd['id']] }
    },
    
    request_types: ->(connection, serviceDeskId:) {
      rts = get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/servicedesk/#{serviceDeskId}/requesttype")['values']
      (rts || []).map { |rt| [rt['name'], rt['id']] }
    }
  }
}
