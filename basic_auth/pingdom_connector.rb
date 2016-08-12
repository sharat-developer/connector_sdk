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

    alert: {
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
  
 actions: {
   
  get_detailed_check_information: {
      
    description: 'get <span class="provider">check information</span> in <span class="provider">pingdom</span>',
      
    input_fields: ->() {[
        {name: 'checkid',type: :integer,label:'Enter your Check ID',hint: 'Go to Monitering->Uptime->select the check you will get your CheckId in the url at the end ',optional: false}
      ]
      },

    execute: ->(connection, input) {
        get("https://api.pingdom.com/api/2.0/checks/#{input['checkid']}")
      },

    output_fields: ->(object_definitions) {
        [ 
          {name: 'check',type: :object,properties:[
           {name: 'id',type: :integer},
           {name: 'name'},
           {name: 'hostname'},
           {name: 'status'},
           {name: 'resolution',type: :integer},
           {name: 'sendtoemail',type: :boolean},
           {name: 'sendtosms',type: :boolean},
           {name: 'sendtosms',type: :boolean},
           {name: 'sendtotwitter',type: :boolean},
           {name: 'sendtoiphone',type: :boolean},
           {name: 'sendtoandroid',type: :boolean},
           {name: 'sendnotificationwhendown',type: :integer},
           {name: 'notifyagainevery',type: :integer},
           {name: 'notifywhenbackup',type: :boolean},
           {name: 'lasterrortime',type: :integer},
           {name: 'lasttesttime',type: :integer}]}
          ]
      }
    }
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
          next_page: (next_created_since.presence || Time.now)
        }
      },

        output_fields: ->(object_definitions) {
        object_definitions['alert']
      }
    }
  },
}


