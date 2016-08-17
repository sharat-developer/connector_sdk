{
  title: 'Hipchat',
  
   connection: {
    fields: [
      {
        name: 'deployment',
        control_type: 'subdomain',
        url:'.hipchat.com',
        optional:false,
        hint: 'Enter your deployment ex.company_name'
       },
      {
        name: 'auth_token',
        control_type: 'password',
        optional:false,
        hint: 'Enter your authentication token'
        },
      ],
    
    authorization: {
      type: 'auth_token',
      credentials: ->(connection) {
        params(auth_token: connection['auth_token'])
       }
     }
   },
  
  object_definitions: {   
    
    message: {
      fields: ->() {
        [
          {name:'id',hint:"ID of the message"},
          {name:'timestamp'}
        ]
      }
     },
    
    response: {
      fields: ->() {
        [
          {name:'date'},
          {name:'from',type: :object,properties:[
            {name:'id'},
            {name:'links',type: :object,properties:[
              {name:'self'}
            ]},
            {name:'mention_name'},
            {name:'name'},
            {name:'version'},
          ]},
          {name:'id'},
          {name:'message'},
          {name:'type'},
          {name:'color'},
          {name:'from'},
          {name:'message_format'},
          {name:'notification_sender',type: :object,properties:[
            {name:'client_id'},
            {name:'id'},
            {name:'type'}
            ]},
          ]
        }
      },
    },
  
  test: ->(connection) {
    get("https://#{connection['deployment']}.hipchat.com/v2/room")
  },
  
  actions: {  
    Post_message: {
     
      description: 'Post <span class="provider">message</span> in <span class="provider">Hipchat</span>',
      
      input_fields: ->() {
        [
          {name:'message',hint:"Valid length range: 1 - 1000",optional:false,label:"Message"},
          {name:'room',hint:"Give either Room ID or Room name",optional:false,label:"Room"}
        ]        
      },
      
      execute: ->(connection, input) {
        post("https://#{connection['deployment']}.hipchat.com/v2/room/#{input['room']}/message",input)
      },
      
      output_fields: ->(object_definitions) {
        object_definitions['message']
      }
     },
    
    Reply_to_message: {
      
      description: 'Reply to<span class="provider">message</span> in <span class="provider">Hipchat</span>',
      
      input_fields: ->() {
        [
          {name:'parentMessageId',hint:"The Id of the message you are replying to",label:"Message ID",optional:false},
          {name:'message',hint:"Valid length range: 1 - 1000",optional:false,label:"Message"},
          {name:'room',hint:"Give either Room ID or Room name",optional:false,label:"Room"}
        ]                
      },
      
      execute: ->(connection, input) {
        post("https://#{connection['deployment']}.hipchat.com/v2/room/#{input['room']}/reply",input)
      },
      
      output_fields: ->(object_definitions) {
        }
     },
  },
  
  triggers: {
    
    New_message: {
      
      description: "New <span class='provider'>message</span> in <span class='provider'>Hipchat</span>",
      
      input_fields: ->() {
        [
          {name:'room',hint:"Select room",control_type: 'select', pick_list: 'room',optional:false,label:"Room"}
        ]
      },
      
      webhook_subscribe: ->(webhook_url, connection, input, flow_id) {
        url = "https://#{connection['deployment']}.hipchat.com/v2/room/#{input['room']}/extension/webhook/#{flow_id}"
        post(url,
          name: "Workato recipe #{flow_id}",
          targetUrl: webhook_url,
          resource: 'messages',
          event: 'room_message')
        { url: url }
       },
      
      webhook_notification: ->(input, payload) {
        payload['items']
      },
      
      webhook_unsubscribe: ->(webhook) {
        delete(webhook[:url])
      },
      
      dedup: ->(message) {
        message['id']
      },
      
      output_fields: ->(object_definitions) {
        object_definitions['response']
      }
     },
   },
  
  pick_lists: {
    room: ->(connection) {
      get("https://railsdata.hipchat.com/v2/room")['items'].
        map { |room| [room['name'], room['id']] }
    }
  },
 }
