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
          { name: 'id' , label: 'Project id' },
          { name: 'name' },
          { name: 'deployId' , type: :integer },
          { name: 'deployAt' , type: :timestamp },
          { name: 'noticeTotalCount' , type: :integer },
          { name: 'rejectionCount' , type: :integer },
          { name: 'fileCount' , type: :integer },
          { name: 'deployCount' , type: :integer },
          { name: 'groupResolvedCount' , type: :integer },
          { name: 'groupUnresolvedCount' , type: :integer }
       ]
     }
    }
   },
  
  actions: {
   
   get_project: {
      
    description: 'Get<span class="provider">project details</span> in <span class="provider">airbrake</span>',
     
    input_fields: ->(object_definitions){
      object_definitions['project'].only('id')
      },
     
    execute: ->(connection, input) {
        get("https://airbrake.io/api/v3/projects/#{input['id']}")
      },
     
    output_fields: ->(object_definitions){[
      
      { name: 'project' , type: :object , properties: object_definitions['project']}
      ]
       }
      }
     }
   }
