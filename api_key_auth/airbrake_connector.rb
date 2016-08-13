{
  title: 'Airbrake',

  connection: {
    fields: [
      {
        name: 'api_key',
        control_type: 'password'
      }
    ],

    authorization: {
      type: 'api_key',

      credentials: ->(connection) {
        params(api_key: connection['api_key'])
      }
    }
  },
  
  test: ->(connection) {
    get("https://airbrake.io/api/v3/projects?key=#{connection['api_key']}")
  },

  object_definitions: {
    project: {
        fields: ->() {
        [ 
          {name: 'id'},
          {name: 'name'},
          {name: 'deployId',type: :integer},
          {name: 'deployAt',type: :timestamp},
          {name: 'noticeTotalCount',type: :integer},
          {name: 'rejectionCount',type: :integer},
          {name: 'fileCount',type: :integer},
          {name: 'deployCount',type: :integer},
          {name: 'groupResolvedCount',type: :integer},
          {name: 'groupUnresolvedCount',type: :integer}
       ]
     }
    }
   },
  
  actions: {
   
   get_project: {
      
    description: 'Get<span class="provider">project</span> in <span class="provider">airbrake</span>',
     
    input_fields: ->(){
      
      [{name: 'id',hint: 'Enter your project ID',optional: false}]
      },
     
      execute: ->(connection, input) {
        get("https://airbrake.io/api/v3/projects/#{input['id']}",input)
      },
     
      
    output_fields: ->(){[
      
     {name: 'project',type: :object,properties:[
      {name: 'id',type: :integer},
      {name: 'name'},
      {name: 'throttles',type: :boolean},
      {name: 'rateLimited',type: :boolean}]}

      ]
      }
     }
    }
   }

