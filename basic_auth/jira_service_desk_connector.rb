{
title: 'JIRA Service Desk',

  connection: {
    fields: [
      {
        name: 'subdomain',
        control_type: 'subdomain',
        url: '.atlassian.net',
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
      fields: ->() {
        [
          { name:'issueId', type: :integer },
          { name:'issueKey' },
          { name: 'serviceDeskId', label: 'ServiceDesk',
            control_type: 'select', pick_list: 'service_desk' },
          { name: 'requestTypeId', Label: 'Request Type',
            control_type: 'select', pick_list: 'request_type', pick_list_params: { service_desk: 'serviceDeskId' } },
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
          ]},
          { name: '_links' , type: :object, properties:[
            { name: 'jiraRest' },
            { name: 'web' },
            { name: 'self'}
          ]}
        ]
      }
    },
       
    comment: {
  		fields: ->() {
  			[
  				{ name: 'id' },
  				{ name: 'body', control_type: 'text-area' },
          { name: 'public', type: :boolean },
          {name: "author",type: :object, properties: [ 
             {name: "name"},
             {name: "key"},
             {name: "emailAddress"},
             {name: "displayName"},
             {name: 'active',type: :boolean},
             {name: "timeZone"},
            { name: "_links", type: :object, properties: [ 
              {name: "jiraRest", type: :url},
              {name: "avatarUrls", type: :object, properties:[
                {name: "48x48"},
                {name: "24x24"},
                {name: "16x16"},
                {name: "32x32"}
              ]},
              {name: "self"},
            ]},
          ]},
          {name: "created",type: :array, properties: [
            {name: "iso8601"},
            {name: "jira"},
            {name: "friendly"},
            {name: "epochMillis"}
          ]},
          { name: "_links", type: :object, properties: [ 
            {name: "self"},
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
          { name: 'searchTerm', hint: 'Enter the keyword for the request', optional: false },
          { name: 'requestStatus' ,control_type: 'select', pick_list: 'request_status' },
          { name: 'requestOwnership' ,control_type: 'select', pick_list: 'request_ownership'},
          { name: 'start' , hint: 'The starting index of the returned objects' ,type: :integer},
          { name: 'limit',hint: 'The maximum number of items to return per page',type: :integer}
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
        get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request")|| []
      }
    },

    create_customer_request: {
     
      description: 'Create <span class="provider">customer request</span> in <span class="provider">JIRA Service Desk</span>',

      input_fields: ->() {
        [
          { name: 'serviceDeskId', label: 'ServiceDesk', optional: false,
            control_type: 'select', pick_list: 'service_desk' },
          { name: 'requestTypeId', Label: 'Request Type', optional: false,
            control_type: 'select', pick_list: 'request_type', pick_list_params: { service_desk: 'serviceDeskId' } },
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
      },
      
      sample_output: ->(connection) {
        get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request")['values'].first || {}
      }
    },
    
    create_comment: {
    	description: 'Create <span class="provider">comment</span> in <span class="provider">JIRA Service Desk</span>',

      input_fields: ->() {
        [
        	{ name: 'Issue', hint: 'Issue Id or Issue Key', optional: false },
         	{ name: 'body',optional: false },
          { name: 'public', type: :boolean ,optional: false}
        ]
      },

	    execute: ->(connection, input) {
        post("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request/#{input.delete('Issue')}/comment", input)
      },

     	output_fields: ->(object_definitions) {
	     	object_definitions['comment']
	    },
      
      sample_output: ->(connection) {
        i =  get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request")['values'].first['issueId']
        j = get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request/#{i}/comment")['values'].first['id']
        k = get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request/#{i}/comment/#{j}")
      },
    },

    get_comment_by_ID: {
    	
      description: 'Get <span class="provider">comment</span> by ID in <span class="provider">JIRA Service Desk</span>',

      input_fields: ->() {
        [
        	{ name: 'Issue', hint: 'Issue Id or Issue Key', optional: false },
          { name: 'commentId',optional: false},
         ]
      },

      execute: ->(connection, input) {
        get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request/#{input['Issue']}/comment/#{input['commentId']}")
      },

      output_fields: ->(object_definitions) {
        object_definitions['comment']
      },
      
      sample_output: ->(connection) {
        i =  get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request")['values'].first['issueId']
        j = get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request/#{i}/comment")['values'].first['id']
        k = get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/request/#{i}/comment/#{j}")
      },
    }
  },
  
  pick_lists: {
    
    service_desk: ->(connection) {
      get("https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/servicedesk")['values'].map do |desk|
        [desk['projectName'], desk['id']]
      end
    },
    
    request_type: ->(connection, service_desk:) {
      url = "https://#{connection['subdomain']}.atlassian.net/rest/servicedeskapi/servicedesk/#{service_desk}/requesttype"
      get(url)['values'].map do |type|
        [type['name'], type['id']]
      end
    },
     
    request_status: ->(connection) {
      [
        ["Closed requests","CLOSED_REQUESTS"],
        ["Open requests","OPEN_REQUESTS"],
        ["All requests","ALL_REQUESTS"]
      ]
    },
    
    request_ownership: ->(connection) {
      [
        ["Owned requests","OWNED_REQUESTS"],
        ["Participated requests","PARTICIPATED_REQUESTS"],
        ["All requests","ALL_REQUESTS"]
      ]
    },
  }
 }
