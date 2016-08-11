{
  title: 'Hipchat',

  connection: {
    fields: [
      {
        name: 'deployment',
        control_type: 'subdomain',
        url:'.hipchat.com',
        optional:false,
        hint: 'enter your deployment ex.comapany_name'
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
          { name:'parentMessageId', hint:"id of the message" },
          { name:'message', optional:false },
          { name:'room_id', hint:"you give either room_id or room_name,one is required" },
          { name:'room_name', hint:"you give either room_id or room_name,one is required" }
        ]
      }
    }
   },

  test: ->(connection) {
    get("https://#{connection['deployment']}.hipchat.com/v2/room")
  },

  actions: {  
    post_message: {
      description: 'Post <span class="provider">Message</span> in <span class="provider">Hipchat</span>',

      input_fields: ->(object_definitions) {
 				object_definitions['message']
      },

      execute: ->(connection, input) {
        h = input.reject { |k,v| k == 'message' }
        room = h.map { |k,v| "#{v}" }.join(',')

        post("https://#{connection['deployment']}.hipchat.com/v2/room/#{room}/message", input)
      },

      output_fields: ->(object_definitions) {
        object_definitions['message']
      }
    },

    Reply_message: {
      description: 'Reply <span class="provider">Message</span> in <span class="provider">Hipchat</span>',

      input_fields: ->(object_definitions) {
 				object_definitions['message'].required("parentMessageId")
      },

      execute: ->(connection, input) {
        h = input.reject{ |k,v| k=='message' }
        h1 = h.reject{ |k,v| k=='parentMessageId' }
        room = h1.map { |k,v| "#{v}" }.join(',')

        post("https://#{connection['deployment']}.hipchat.com/v2/room/#{room}/reply",input)
      },

      output_fields: ->(object_definitions) {
        object_definitions['message']
      }
    },
  }
}
