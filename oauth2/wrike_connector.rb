{
  title: 'Wrike',

  connection: {
    authorization: {
      type: 'oauth2',

      authorization_url: ->() {
        'https://www.wrike.com/oauth2/authorize?response_type=code'
      },

      token_url: ->() {
        'https://www.wrike.com/oauth2/token'
      },

      client_id: 'YOUR_WRIKE_CLIENT_ID',

      client_secret: 'YOUR_WRIKE_CLIENT_SECRET',

      credentials: ->(connection, access_token) {
        headers('Authorization': "Bearer #{access_token}")
      }
    }
  },

  object_definitions: {

    task: {
      fields: ->() {
        [
          { name: 'id' },
          { name: 'accountId' },
          { name: 'title' },
          { name: 'description' },
          { name: 'briefDescription' },
          { name: 'status' },
          { name: 'importance' },
          { name: 'createdDate', type: :timestamp },
          { name: 'updatedDate', type: :timestamp },
          { name: 'dates', type: :object, properties: [
             { name: 'type' },
             { name: 'duration', type: :integer},
             { name: 'start', type: :timestamp },
             { name: 'due', type: :timestamp }
          ]},
          { name: 'scope' },
          { name: 'customStatusId' },
          { name: 'hasAttachments', type: :boolean },
          { name: 'attachmentCount', type: :integer },
          { name: 'permalink', control_type: 'url' },
          { name: 'priority' }
        ]
      },
    }
  },

  actions: {

    get_task_by_id: {
      input_fields: ->(object_definitions) {
        [
          { name: 'id', optional: false }
        ]
      },

      execute: ->(connection,input) {
        {
          'task': get("https://www.wrike.com/api/v3/tasks/#{input['id']}")['data'].first
        }
      },

      output_fields: ->(object_definitions) {
        [
          { name: 'task', type: :object, properties: object_definitions['task'] }
        ]
      }
    },

    search_task: {
      input_fields: ->(object_definitions) {
        [
          { name: 'created_after' },
          { name: 'title', hint: 'Searches for exact match'},
          { name: 'status', hint: 'Accepted values are Active, Completed, Deferred and Cancelled'},
          { name: 'importance', hint: 'Accepted values are High, Normal and Low'},
        ]
      },

      execute: ->(connection,input) {
        if input['created_after'].present?
          created_date_query = '?createdDate={"start":"' + input['created_after'].to_time.utc.iso8601 + '"}'
          input = input.reject { |k,v| k == 'created_after' }
        end

        {
          'tasks': get("https://www.wrike.com/api/v3/tasks" + (created_date_query || ""), input)['data']
        }
      },

      output_fields: ->(object_definitions) {
        [
          { name: 'tasks', type: :array, of: :object, properties: object_definitions['task'] }
        ]
      }
    },

    create_task: {
      input_fields: ->(object_definitions) {
        [
          { name: 'folder_id', control_type: 'select', pick_list: 'folder' },
          { name: 'title' },
          { name: 'responsibles', control_type: 'select', pick_list: 'user' },
          { name: 'description' },
          { name: 'status', hint: 'Accepted values are Active, Completed, Deferred and Cancelled' },
          { name: 'importance', hint: 'Accepted values are High, Normal and Low' }
        ]
      },

      execute: ->(connection,input) {
        updated_input = input.reject { |k,v| k != 'folder_id' }

        {
          'task': post("https://www.wrike.com/api/v3/folders/#{input['folder_id']}/tasks").params(updated_input)['data'].first
        }
      },
      
      output_fields: ->(object_definitions) {
        [{ name: 'task', type: :object, properties: object_definitions['task'] }]
      }
    },

    update_task: {
      input_fields: ->(object_definitions) {
        [
          { name: 'id', optional: false },
          { name: 'title'},
          { name: 'description' },
          { name: 'status', hint: 'Accepted values are Active, Completed, Deferred and Cancelled' },
          { name: 'importance', hint: 'Accepted values are High, Normal and Low' }
        ]
      },

      execute: ->(connection,input) {
        updated_input = input.reject { |k,v| k == 'id' }

        {
          'task': put("https://www.wrike.com/api/v3/tasks/#{input['id']}").params(updated_input)['data'].first
        }
      },

      output_fields: ->(object_definitions) {
        [
          { name: 'task', type: :object, properties: object_definitions['task'] }
        ]
      }
    }
  },

  triggers: {

    new_or_updated_task: {

      input_fields: ->(object_definition) {
        [
          { name: 'since', type: :timestamp }
        ]
      },

      poll: ->(connection,input,last_updated_at) {
        since = (last_updated_at || input['since'] || Time.now).to_time.utc.iso8601

        updated_since = '{"start":"' + since + '"}'

        tasks = get("https://www.wrike.com/api/v3/tasks?updatedDate=#{updated_since}").
                  params(sortField: 'UpdatedDate',
                         pageSize: 10)['data']

        next_updated_at = tasks.first['updatedDate'] unless tasks.length == 0

        {
          events: tasks,
          next_poll: next_updated_at,
          can_poll_more: tasks.length == 10
        }
      },

      dedup: ->(task) {
        task['id']
      },

      output_fields: ->(object_definitions) {
        object_definitions['task']
      }
    }
  },

  pick_lists: {
    folder: ->(connection) {
      get("https://www.wrike.com/api/v3/folders")['data'].
        map { |folder| [folder['title'], folder['id']] }
    },

    user: ->(connection) {
      get("https://www.wrike.com/api/v3/contacts")['data'].
        map { |contact| [contact['firstName'] + " " + contact['lastName'], contact['id']] }
    }
  }
}
