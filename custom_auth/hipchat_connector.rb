{
  title: 'Hipchat',

  connection: {
    fields: [
      {
        name: 'deployment',
        control_type: 'subdomain',
        url:'.hipchat.com',
        optional:false,
        hint: 'enter your deployment ex.company_name'
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
          { name:'parentMessageId', hint: "id of the message" },
          { name:'message', optional: false },
          { name:'room_id_or_room_name', hint:"give either room_id_or_room_name", optional: false }
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
        object_definitions['message'].ignored('parentMessageId')
      },

      execute: ->(connection, input) {
        payload = input.reject { |k,v| k == 'room_id_or_room_name' }

        post("https://#{connection['deployment']}.hipchat.com/v2/room/#{input['room_id_or_room_name']}/message", payload)
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
        payload = input.reject { |k,v| k == 'room_id_or_room_name' }

        post("https://#{connection['deployment']}.hipchat.com/v2/room/#{input['room_id_or_room_name']}//reply", payload)
      },

      output_fields: ->(object_definitions) {
        object_definitions['message']
      }
    }
  }
}
