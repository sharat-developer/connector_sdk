{
  title: 'Pingdom',
    connection: {
    fields: [
      
      {
        name: 'app_key',
        optional: false,
        label: 'Application key'
      },
    
      {
        name: 'username',
        optional: true,
        hint: 'Your username'
      },
      {
        name: 'password',
        control_type: 'password',
        label: 'Password'
      }
    ],

  authorization: {
      type: 'basic_auth',
      credentials: ->(connection) {    
          user(connection['username'])
          password(connection['password'])
          headers('App-Key': connection['app_key'])
      }
    }
  },

  object_definitions: {

    actions: {
      fields: ->() {
        [
          {name: 'from',type: :integer},
          {name: 'to',type: :integer},
          {name: 'limit',type: :integer},
          {name: 'offset',type: :integer},
          {name: 'checkids'},
          {name: 'contactids'},
          {name: 'status'},
          {name: 'via'}
        ]
      },
      }
    },
   test: ->(connection) {
    get("https://api.pingdom.com/api/2.0/actions")
  },

 triggers: {

    new_alert: {
      
       description: 'New <span class="provider">alert</span> in <span class="provider">pingdom</span>',
      
       type: :paging_desc,

       input_fields: ->() {
        [
          {
            name: 'since',
            type: :timestamp,
            optional: false
          }
        ]
      },

        poll: ->(connection, input, last_created_since) {
          
        created_since = (last_created_since || input['since'] || Time.now)

        response = get("https://api.pingdom.com/api/2.0/actions?from=#{input['since'].to_i}")                

        next_created_since = response['actions']['alerts'].last['time'] unless response['actions']['alerts'].blank?
        
        {
          events: response['actions']['alerts'],
          next_page: (last_created_since.presence || Time.now)
        }
      },

        output_fields: ->(object_definitions) {
        object_definitions['actions']
      }
    }
  },
}

