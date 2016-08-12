{
title: 'Codeship',
connection: {

  fields: [
   {
      name: 'api_key',
      control_type: 'password',
      label: 'API key',
      optional:false
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
   project: {
      fields: ->() {
        [ 
          {name:'id',hint:"Id of the particular project"},
          {name:'uuid'},
          {name:'repository_name'},
          {name:'repository_provider'},
          {name: 'builds', type: :array,of: :object, properties: [
          {name:'id',hint:"Id of the particular build"},
          {name:'uuid'},
          {name:'status'},
          {name:'project_id',hint:"Id of the particular project"},  
          {name:'branch',hint:"Name of the branch"},
          {name:'commit_id',hint:"Id of the commited build"},
          {name:'github_username',hint:"User of the github for particular build"},
          {name:'message',hint:"Message of your build"},
          {name:'started_at',type: :datetime},
          {name:'finished_at',type: :datetime},
          ]},
          ]
    }
   }
    },
 test: ->(connection) {
    get("https://codeship.com/api/v1/projects")
    },
   actions: {  
    List_builds: {
     description: 'List <span class="provider">Builds</span> in <span class="provider">Codeship</span>',
     input_fields: ->() {
 			 [
         {name:'project_id',optional:false}
         ]
      },
      execute: ->(connection, input) {
       get("https://codeship.com/api/v1/projects/#{input['project_id']}")
        },
     output_fields: ->(object_definitions) {
        object_definitions['project']
      }
    },
     Restart_build: {
     description: 'Restart <span class="provider">Build</span> in <span class="provider">Codeship</span>',
     input_fields: ->() {
 						 [
               {name:'id',optional:false,hint:"Id of the particular build",label:"Build_Id"}
               ]
      },
      execute: ->(connection, input) {
       post("https://codeship.com/api/v1/builds/#{input['id']}/restart")
        },
     output_fields: ->(object_definitions) {
        [
          {name:'id',hint:"Id of the particular build"},
          {name:'uuid'},
          {name:'status'},
          {name:'project_id',hint:"Id of the particular project"},  
          {name:'branch',hint:"Name of the branch"},
          {name:'commit_id',hint:"Id of the commited build"},
          {name:'github_username',hint:"User of the github for particular build"},
          {name:'message',hint:"Message of your build"},
          {name:'started_at',type: :datetime},
          {name:'finished_at',type: :datetime},
          {name:'debug_connection'}  
         ]
      }
    },
    }
  }
