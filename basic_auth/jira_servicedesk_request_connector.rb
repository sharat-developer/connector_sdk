{
  title: 'Jira Servicedesk',
  
  connection: {
    fields: [
      {
        name: 'company',
        control_type: 'subdomain',
        url: '.atlassian.net',
        hint: 'Your helpdesk name as found in your Freshdesk URL'
      },
      {
        name: 'username',
        optional: true,
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
        user(connection['username'])
        password(connection['password'])
      }
    }
  },
  
  test: ->(connection) {
    get("https://#{connection['company']}.atlassian.net/rest/servicedeskapi/request")
  },
  
  object_definitions: {
    request:{
      fields: ->() {
        [
          {name: 'searchTerm',hint:'Enter the keyword for the request',optional: false},
          {name: 'requestOwnership'},
          {name: 'serviceDeskId'},
          {name: 'requestTypeId',type: :integer},
          {name: 'start',type: :integer},
          {name: 'limit',type: :integer}
        ]
        }
      }
    },
 
 actions:{
    get_my_customer_requests:{
      
      description: 'Get <span class="provider">My customer request</span> in <span class="provider">jira servicedesk</span>',
     
      input_fields: ->(object_definitions) {
        object_definitions['request']
      },
    
      execute: ->(connection, input) {
         get("https://#{connection['company']}.atlassian.net/rest/servicedeskapi/request",input)
       },
      
      output_fields: ->(object_definitions) {
        object_definitions['request']
     }
    },
   
  
  create_customer_request:{
    
    input_fields: ->() { [
      {name: 'serviceDeskId',type: :integer,optional: false},
      {name: 'requestTypeId',type: :integer,optional: false},
      {name: 'requestFieldValues_summary',label:'Summary',optional: false},
      {name: 'requestFieldValues_description',label:'Description',optional: false}
      ]
      },
    
     execute: ->(connection, input) {
          hash = {
              "requestFieldValues" => {'summary'=>            input['requestFieldValues_summary'],'description'=>input['requestFieldValues_description']}
         } 
          input.delete('requestFieldValues_summary')
          input.delete('requestFieldValues_description')
          post("https://#{connection['company']}.atlassian.net/rest/servicedeskapi/request",input).payload(hash)
       },
    
    output_fields: ->(){[ 
      {name:'_expands'},
      {name:'issueId'},
      {name:'issueKey'},
      {name:'requestTypeId'},
      {name:'serviceDeskId'},
      {name:'createdDate'},
      {name:'reporter'},
      {name:'requestFieldValues'},
      {name:'currentStatus'}
      ]
      }
     }
  },
  }
