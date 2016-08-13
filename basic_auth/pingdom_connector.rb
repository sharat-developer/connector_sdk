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

    output_fields: ->() {
        [ 
          {name: 'check',type: :object,properties:[
           {name: 'id',type: :integer},
           {name: 'name'},
           {name: 'hostname'},
           {name: 'status'},
           {name: 'resolution',type: :integer},
           {name: 'sendtoemail',type: :boolean},
           {name: 'sendtosms',type: :boolean},
           {name: 'sendnotificationwhendown',type: :integer},
           {name: 'notifyagainevery',type: :integer},
           {name: 'notifywhenbackup',type: :boolean},
           {name: 'contactids',type: :integer}]}
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

        poll: ->(connection, input, page) {
          limit = 100
          page ||= 0
        	created_since = (input['since'] || Time.now).to_i
					offset = (limit * page)
        	response = get("https://api.pingdom.com/api/2.0/actions?from=#{created_since}&limit=100&offset=#{offset}")                
        	next_created_since = response['actions']['alerts'].last['time'] if response['actions']['alerts'].present?
          page = page + 1
        {
          events: response['actions']['alerts'],
          next_page: page
        }
      },
       sort_by: ->(response) {
         response['time']
      },

        output_fields: ->() {
         [ 
           {name: 'contactname'},
           {name: 'contactid',type: :integer},
           {name: 'time',type: :integer},
           {name: 'via'},
           {name: 'status'},
           {name: 'messageshort'},
           {name: 'messagefull'},
           {name: 'sentto'}
         ]
        }
      }
  },
}

