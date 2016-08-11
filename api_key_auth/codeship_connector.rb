{
  title: 'codeship',

  connection: {

    fields: [
     {
        name: 'api_key',
        control_type: 'password',
        label: 'API key'
      }
    ],

    authorization: {
      type: 'api_key',

      credentials: ->(connection) {
        params(api_key: connection['api_key'])
      }
    }
  },

  object_definitions: {   
    build: {
      fields: ->() {
        [ 
          { name:'id', hint:"id of the particular build" },
          { name:'project_id', hint:"id of the particular project" },
        ]
      }
    }
   },

  test: ->(connection) {
    get("https://codeship.com/api/v1/projects")
  },

  actions: {  

    list_builds: {
      description: 'List <span class="provider">Builds</span> in <span class="provider">Codeship</span>',

      input_fields: ->(object_definitions) {
        object_definitions['build'].required("project_id")
      },
      execute: ->(connection, input) {
        get("https://codeship.com/api/v1/projects/#{input['project_id']}")
      },

      output_fields: ->(object_definitions) {
        object_definitions['build']
      }
    },

    restart_build: {
     description: 'Restart <span class="provider">Build</span> in <span class="provider">Codeship</span>',

      input_fields: ->(object_definitions) {
        object_definitions['build'].required("id")
      },

      execute: ->(connection, input) {
        post("https://codeship.com/api/v1/builds/#{input['id']}/restart")
      },

      output_fields: ->(object_definitions) {
        object_definitions['build']
      }
    },
  }
}
