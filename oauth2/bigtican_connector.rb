{
 title: 'Bigtincan Hub',

 connection: {

    fields: [
      {
        name: 'account_id',
        optional: false,
        hint: 'Your Public API account ID'
      }
    ],

    authorization: {
     type: 'oauth2',

    authorization_url: ->() {
     'https://pubapi.bigtincan.com/services/oauth/authorize?response_type=code&device_id=hub_auth'
    },

    token_url: ->() {
     'https://pubapi.bigtincan.com/services/oauth/token'
    },

    client_id: 'YOUR_OAUTH_CLIENT_ID',

    client_secret: 'YOUR_OAUTH_CLIENT_SECRET',

    credentials: ->(connection, access_token) {
        headers('Authorization': "Bearer #{access_token}")
    }
  }
 },

  object_definitions: {

    channel: {

      fields: ->() {
        [
          {
            name: 'id',
            type: 'string'
          },
          {
            name: 'name',
            type: 'string'
          },
          {
            name: 'channel_type',
            type: 'string'
          }
        ]
      }
    },


    single_story: {
      fields: ->() {
        [
          {
            name: 'revision_id',
            type: 'string'
          },
          {
            name: 'perm_id',
            type: 'string'
          },
          { name: 'title',
            type: 'string'
          },
          {
            name: 'channels',
            type: :array,
            of: :object,
            properties: [
              { name: 'id', type: 'string'}
            ]
          }
        ]
      }
      },

    single_form: {
      fields: ->() {
        [
          {
            name: 'id',
            type: 'string'
          },
          {
            name: 'name',
            type: 'string'
          }
        ]
      }

    },

    single_form_category: {

      fields: ->() {
        [
          {
            name: 'id',
            type: 'string'
          },
          {
            name: 'name',
            type: 'string'
          },
          {
            name: 'note',
            type: 'string'
          }
        ]
      }
    },

    form_submission_data: {
          fields: ->(connection, config_fields) {
            [
              {
                 name: 'submission_key',
                 type: 'string'
              },
              {
                name: 'user_id',
                type: 'string'
              },
              {
                name: 'user_name',
                type: 'string'
              },
              {
                name: 'cursor',
                type: 'string'
              },
              {
                name: 'data',
                type: :object,
                properties:
                  if config_fields['form_id'].present?
                    fields = get("https://pubapi.bigtincan.com/#{connection['account_id']}/alpha/form/get/#{config_fields['form_id']}")['data']['form_data']['fields']
                    fields.select { |field| field['label'].present? }.
                           map do |field|
                             {
                               name: field['label'].gsub(/[ ]/, '_').downcase,
                               label: field['label'],
                               type: 'string'
                             }
                           end
                  end
              }
            ]
          }
        }
  },

  actions: {

   #form: form/get
   get_form: {
         input_fields: ->() {
            [
              { name: 'form_id', optional: false },
              { name: 'include_data_sources', optional: true },
            ]
         },

         execute: ->(connection, input) {

           if input['include_data_sources'].blank?
                input['include_data_sources'] = true
           end

           get("https://pubapi.bigtincan.com/#{connection['account_id']}/alpha/form/get/#{input['form_id']}").params(include_data_sources: input['include_data_sources'])['data']

         },

           output_fields: ->(object_definitions) {
           [
            { name: 'id', type: 'string' },
            { name: 'name', type: 'string' },
            { name: 'form_data',
              type: :object,
              properties: [
                { name: 'fields', type: :array, of: :object, properties: [
                    { name: 'type', type: 'string'},
                    { name: 'value', type: 'string'},
                    { name: 'label', type: 'string'},
                  ] }
              ]
            }
           ]
         },
    },

    #story: story/get
    get_story: {
      input_fields: ->() {
         [
           { name: 'story_perm_id', optional: false },
         ]
      },
      execute: ->(connection, input) {
        get("https://pubapi.bigtincan.com/#{connection['account_id']}/alpha/story/get/#{input['story_perm_id']}")
      },
      output_fields: ->(object_definitions) {
        [

         { name: 'trace_id',  type: 'string'},

         {
           name: 'data',
           type: :object,
           properties: object_definitions['single_story']
         },
        ]
      }
    },


    #story: story/all
    list_stories: {

         input_fields: ->() {
            [
              { name: 'channel_id', optional: true }
            ]
         },
         execute: ->(connection, input) {
            get("https://pubapi.bigtincan.com/#{connection['account_id']}/alpha/story/all").params({limit:100})
         },
         output_fields: ->(object_definitions) {
           [
            { name: 'page',  type: 'integer'},
            { name: 'page_total',  type: 'integer'},
            { name: 'limit',  type: 'integer'},
            { name: 'total_count',  type: 'integer'},
            { name: 'next_page',  type: 'integer'},
            { name: 'prev_page',  type: 'integer'},
            { name: 'current_count',  type: 'integer'},
            { name: 'data',
                type: :array,
                of: :object,
                properties: object_definitions['single_story']},
           ]
         }
    },

    #story: story/add
    create_story: {
      input_fields: ->() {
         [
           { name: 'title', optional: false },
           { name: 'description', optional: false },
           { name: 'channel_id', optional: false },
         ]
      },
      execute: ->(connection, input) {

        payload_object = { title: input['title'], description: input['description'], channels: [{id: input['channel_id']}] }

        if input['title'].blank?
             payload_object = { description: input['description'], channels: [{id: input['channel_id']}] }
        end
        if input['description'].blank?
             payload_object = { title: input['title'], channels: [{id: input['channel_id']}] }
        end

        post("https://pubapi.bigtincan.com/#{connection['account_id']}/alpha/story/add").payload(payload_object)
      },

      output_fields: ->(object_definitions) {
        [
          {
             name: 'data',
             type: :object,
             properties: object_definitions['single_story']
          },
        ]
      }
    },

    #story: story/edit
    update_story: {
      input_fields: ->() {
         [
           { name: 'title', optional: true },
           { name: 'description', optional: true },
           { name: 'channel_id', optional: false },
           { name: 'revision_id', optional: false },
         ]
      },
      execute: ->(connection, input) {

        payload_object = { title: input['title'], description: input['description'], channels: [{id: input['channel_id']}]}

        if input['title'].blank?
             payload_object = { description: input['description'], channels: [{id: input['channel_id']}]}
        end
        if input['description'].blank?
             payload_object = { title: input['title'], channels: [{id: input['channel_id']}]}
        end

        put("https://pubapi.bigtincan.com/#{connection['account_id']}/alpha/story/edit/#{input['revision_id']}").payload(payload_object)['data']
      },

      output_fields: ->(object_definitions) {
        object_definitions['single_story']
      }
    },

    #story: story/delete
    delete_story: {

    input_fields: ->() {
         [
           { name: 'revision_id', optional: false },
         ]
      },
   execute: ->(connection, input) {
        delete("https://pubapi.bigtincan.com/#{connection['account_id']}/alpha/story/archive/#{input['revision_id']}")['data']
   },
   output_fields: ->(object_definitions) {
        [
         {name:'deleted', type:'boolean'}
        ]
    }
   },

  },

  triggers: {

    new_form_submission: {

      type: :paging_desc,

       config_fields: [
          {
             name: 'form_id',
             label: 'Form ID',
             optional: false,
          }
       ],

      poll: ->(connection, input, page) {
        page ||= 1

        response = get("https://pubapi.bigtincan.com/#{connection['account_id']}/alpha/form/data/#{input['form_id']}").
                    params(limit: 30,
                           page: page,
                           sort: 'desc')['data']

        {
          events: response['submissions'],
          next_page: response['submission_next_page'],
        }
      },

      document_id: ->(submission) {
        submission['cursor']
      },

      output_fields: ->(object_definitions) {
        object_definitions['form_submission_data']
      }

    },

    new_story: {

      type: :paging_desc,

      input_fields: ->() {
        [
           { name: 'channel_id', optional: false, type: :string }
        ]
      },

      poll: ->(connection, input, page) {

        page ||= 1

         #desc by default
         stories = get("https://pubapi.bigtincan.com/#{connection['account_id']}/alpha/story/all").params(limit: 30, page: page, channel_id:input['channel_id'])


        {
          next_page: stories['next_page'],
          events: stories['data'],
        }
      },

      document_id: ->(story) {
        story['revision_id']
      },

      output_fields: ->(object_definitions) {
        object_definitions['single_story']
      }
    }
  }
}
