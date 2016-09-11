{
 title: 'Bigtincan Hub',

 connection: {

    fields: [
      {
        name: 'account_id',
        optional: false,
        hint: 'Your Pub API account ID'
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
      fields: ->() {
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
            type: :object
          }
        ]
      }
    }
  },

  actions: {
   # form: form/data
    form_data: {

      input_fields: ->() {
         [
           { name: 'account_id', optional: false },
           { name: 'form_id', optional: false },
           { name: 'page', optional: true },
           { name: 'limit', optional: true },
         ]
      },

      execute: ->(connection, input) {
        if input['page'].blank?
             input['page'] = 1
        end

        if input['limit'].blank?
             input['limit'] = 10
        end

        get("https://pubapi.bigtincan.com/#{input['account_id']}/alpha/form/data/#{input['form_id']}").params(page: input['page'], limit: input['limit'])
      },

      output_fields: ->(object_definitions) {
        [
         {
             name: 'data',
             type: :array,
         },
        ]
      }
    },
    # form: form/all
    form_all: {
      input_fields: ->() {
         [
           { name: 'account_id', optional: false },
           { name: 'category_id', optional: true },
           { name: 'page', optional: true },
           { name: 'limit', optional: true },
         ]
      },

      execute: ->(connection, input) {

        if input['page'].blank?
             input['page'] = 1
        end

        if input['limit'].blank?
             input['limit'] = 10
        end

        if input['category_id'].blank?
           get("https://pubapi.bigtincan.com/#{input['account_id']}/alpha/form/all").params( page: input['page'], limit: input['limit'])
        else
           get("https://pubapi.bigtincan.com/#{input['account_id']}/alpha/form/all").params(category_id: input['category_id'], page: input['page'], limit: input['limit'])
        end
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
             properties: object_definitions['single_form']},
        ]
      }
    },

      #form: form_category/all

      form_category_all: {

      execute: ->(connection, input) {
        get("https://pubapi.bigtincan.com/#{connection['account_id']}/alpha/form_category/all")
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
             properties: object_definitions['single_form_category']},
        ]
      }
    },

   #form: form/get
   form_get: {
      input_fields: ->() {
         [
           { name: 'form_id', optional: false },
           { name: 'include_data_sources', optional: true },
         ]
      },

      execute: ->(connection, input) {

        if input['include_data_sources'].blank?
             input['include_data_sources'] = 'true'
        end

        get("https://pubapi.bigtincan.com/#{connection['account_id']}/alpha/form/get/#{input['form_id']}").params(form_id: input['form_id'], include_data_sources: input['include_data_sources'] )

      },

      output_fields: ->(object_definitions) {
        [
         { name: 'data',
             type: :array,
             of: :object,
             properties: [
               {name: 'id', type: 'string'},
               {name: 'name', type: 'string'},
               {name: 'form_data', type: :array, of: :object}
             ]
         },
        ]
      }
    },


    #story: story/all
    story_all: {
      input_fields: ->() {
         [
           { name: 'channel_id', optional: true }
         ]
      },
      execute: ->(connection, input) {
        get("https://pubapi.bigtincan.com/#{connection['account_id']}/alpha/story/all").params(channel_id: input['channel_id'])
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

    #story: story/get
    story_get: {
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

         { name: 'data',
             type: :object,
             properties: object_definitions['single_story']},
        ]
      }
    },

    #story: story/add
    story_add: {
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
    story_edit: {
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

        put("https://pubapi.bigtincan.com/#{connection['account_id']}/alpha/story/edit/#{input['revision_id']}").payload(payload_object)
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

    #story: story/delete
    story_delete: {

    input_fields: ->() {
         [

           { name: 'revision_id', optional: false },

         ]
      },
   execute: ->(connection, input) {
        delete("https://pubapi.bigtincan.com/#{connection['account_id']}/alpha/story/archive/#{input['revision_id']}")
      },
   output_fields: ->(object_definitions) {
        [
         { name: 'data',
           type: :object,
           properties: [
             {name:'deleted', type:'boolean'}
          ]},
        ]
      }
   },

  #channal: channel/all
  channel_all: {

      execute: ->(connection, input) {
        get("https://pubapi.bigtincan.com/#{connection['account_id']}/alpha/channel/all")
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
             properties: object_definitions['channel']},
        ]
      }
    },
  },

  triggers: {

    new_form_submission: {

      type: :paging_desc,

      input_fields: ->() {
        [
          { name: 'account_id', optional: false, type: :string },
          { name: 'form_id', optional: false, type: :string }
        ]
      },

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

    each_story: {

      type: :paging_desc,

      input_fields: ->() {
        [
           { name: 'channel_id', optional: false, type: :string },
           { name: 'limit', optional: true}
        ]
      },

      poll: ->(connection, input, page) {

        page ||= 1

        if input['limit'].blank?
            limit = 10
        else
            limit = input['limit']
        end

         stories = get("https://pubapi.bigtincan.com/#{connection['account_id']}/alpha/story/all").params(limit: limit, page: page, channel_id:input['channel_id'])


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
