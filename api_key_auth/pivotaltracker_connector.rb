{
  title: 'Pivotal Tracker',
  connection: {
    fields: [
      {
        name: 'api_key', 
        type: :password,      
        hint: 'Personal API key',
        label: 'API key'
      }
    ],

    authorization: {
      type: 'api_key',
      credentials: ->(connection) {
        headers("X-TrackerToken": connection['api_key'])
      }
    }
  },

  object_definitions: {
    story:{
      fields: ->() {
        [
          { name: 'id', type: :integer },
          { name: 'project_id', type: :integer, optional: false, hint: 'Your project ID' },
          { name: 'name', optional: false, hint: 'Name of your story' },
          { name: 'description' },
          { name: 'story_type', control_type: :select, pick_list: "story_type" },
          { name: 'current_state', control_type: :select, pick_list: "current_state" },
          { name: 'estimate', type: :integer },
          { name: 'accepted_at', type: :datetime },
          { name: 'deadline', type: :datetime },
          { name: 'requested_by_id', type: :integer },
          { name: 'owner_by_id', type: :integer },
          { name: 'owner_ids', type: :array, of: :object, properties: [
          ]},
          { name: 'labels', type: :array, of: :object, properties: [
            { name: 'id', type: :integer },
            { name: 'project_id', type: :integer, optional: false },
            { name: 'name' },
            { name: 'created_at', type: :datetime },
            { name: 'updated_at', type: :datetime },
            { name: 'counts', type: :integer },
            { name: 'kind' }
          ]},
          { name: 'tasks', type: :array, of: :object, properties: [
            { name: 'id', type: :integer },
            { name: 'project_id', type: :integer, optional: false },
            { name: 'story_id', type: :integer, optional: false },
            { name: 'description', optional: false },
            { name: 'complete', type: :boolean },
            { name: 'position', type: :integer },
            { name: 'created_at', type: :datetime },
            { name: 'updated_at', type: :datetime },
            { name: 'kind' }
          ]},
          { name: 'comments', type: :array, of: :object, properties: [
            { name: 'id', type: :integer },
            { name: 'project_id', type: :integer, optional: false },
            { name: 'story_id', type: :integer, optional: false },
            { name: 'text' },
            { name: 'person_id', type: :integer },
            { name: 'created_at', type: :datetime },
            { name: 'updated_at', type: :datetime },
            { name: 'file_attachments', type: :array, of: :object, properties: [
              { name: 'id', type: :integer },
              { name: 'filename' },
              { name: 'created_at', type: :integer },
              { name: 'uploader_id', type: :integer },
              { name: 'thumbnailable', type: :boolean },
                { name: 'height', type: :integer },
              { name: 'width', type: :integer },
              { name: 'size', type: :integer },
              { name: 'downoad_url', type: :string },
              { name: 'content_type' },
              { name: 'uploaded', type: :boolean },
              { name: 'big_url' },
              { name: 'thumbnail_url' },
              { name: 'kind' }
            ]},
            { name: 'google_attachments', type: :array, of: :object, properties: [
              { name: 'id', type: :integer },
              { name: 'comment_id', type: :integer },
              { name: 'person_id', type: :integer },
              { name: 'google_kind' },
              { name: 'title' },
              { name: 'google_id' },
              { name: 'alternate_link' },
              { name: 'resource_id' },
              { name: 'kind' }
            ]},
            { name: 'commit_identifier' },
            { name: 'commit_type' },
            { name: 'kind' }
          ]},
          { name: 'created_at', type: :datetime },
          { name: 'updated_at', type: :datetime },
          { name: 'integration_id', type: :integer },
          { name: 'external_id', type: :integer },
          { name: 'url' },
          { name: 'transitions', type: :array, of: :object, properties: [
          ]},
          { name: 'cycle_time_details', type: :object, properties: [
          ]},
          { name: 'kind' },
        ]
      }
    },
    
    comment:{
      fields: ->() {
        [
          { name: 'id', type: :integer },
          { name: 'project_id', type: :integer, optional: false, hint: 'Your project ID' },
          { name: 'story_id', type: :integer, optional: false, hint: 'Id of the story to which you want to comment' },
          { name: 'text', optional: false, hint: 'Your comment' },
          { name: 'person_id', type: :integer },
          { name: 'created_at', type: :datetime },
          { name: 'updated_at', type: :datetime },
          { name: 'file_attachments', type: :array, of: :object, properties: [
            { name: 'id', type: :integer },
            { name: 'filename' },
            { name: 'created_at', type: :integer },
            { name: 'uploader_id', type: :integer },
            { name: 'thumbnailable', type: :boolean },
            { name: 'height', type: :integer },
            { name: 'width', type: :integer },
            { name: 'size', type: :integer },
            { name: 'downoad_url', type: :string },
            { name: 'content_type' },
            { name: 'uploaded', type: :boolean },
            { name: 'big_url' },
            { name: 'thumbnail_url' },
            { name: 'kind' }
            ]},
          { name: 'google_attachments', type: :array, of: :object, properties: [
            { name: 'id', type: :integer },
            { name: 'comment_id', type: :integer },
            { name: 'person_id', type: :integer },
            { name: 'google_kind' },
            { name: 'title' },
            { name: 'google_id' },
            { name: 'alternate_link' },
            { name: 'resource_id' },
            { name: 'kind' }
            ]},
          { name: 'commit_identifier' },
          { name: 'commit_type' },
          { name: 'kind' }
        ]
      }
    },
    
    task:{
      fields: ->() {
        [
          { name: 'id', type: :integer, hint: 'Task ID' },
          { name: 'project_id', type: :integer, optional: false, hint: 'Your project ID' },
          { name: 'story_id', type: :integer, optional: false, hint: 'Id of the story to which you want to comment' },
          { name: 'description', optional: false, hint: 'description of your story' },
          { name: 'complete', type: :boolean },
          { name: 'position', type: :integer },
          { name: 'created_at', type: :datetime },
          { name: 'updated_at', type: :datetime },
          { name: 'kind' }
        ]
      }
    },
  },

  test: ->(connection) {
    get("https://www.pivotaltracker.com/services/v5/projects")
  },

  actions: {
    create_story: {
      description: 'create <span class="provider">story</span> in <span class="provider">pivotaltracker</span>',

      input_fields: ->(object_definitions) {
        object_definitions['story'].only('project_id', 'name','description','story_type','current_state')
      },

      execute: ->(connection, input) {      
        post("https://www.pivotaltracker.com/services/v5/projects/#{input['project_id']}/stories" ,input)
      },

      output_fields: ->(object_definitions) {       
        object_definitions['story']
      }
    },

    create_comment: {
      description: 'create <span class="provider">task</span> in <span class="provider">pivotaltracker</span>',

      input_fields: ->(object_definitions) {
        object_definitions['comment'].only('project_id', 'story_id','text').required('text')
      },

      execute: ->(connection, input) {      
        post("https://www.pivotaltracker.com/services/v5/projects/#{input['project_id']}/stories/#{input['story_id']}/comments" ,input)
      },

      output_fields: ->(object_definitions) {       
        object_definitions['comment']
      }
    },
    
    create_task: {
      description: 'create <span class="provider">task</span> in <span class="provider">pivotaltracker</span>',

      input_fields: ->(object_definitions) {
        object_definitions['task'].only('project_id', 'story_id','description')
      },

      execute: ->(connection, input) {      
        post("https://www.pivotaltracker.com/services/v5/projects/#{input['project_id']}/stories/#{input['story_id']}/tasks" ,input)
      },

      output_fields: ->(object_definitions) {       
        object_definitions['task']
      }
    },
    
    search_task_by_id: {
      description: 'search <span class="provider">task</span> in <span class="provider">pivotaltracker</span>',

      input_fields: ->(object_definitions) {
       object_definitions['task'].only('project_id', 'story_id','id').required('id')
      },

      execute: ->(connection, input) {
        get("https://www.pivotaltracker.com/services/v5/projects/#{input['project_id']}/stories/#{input['story_id']}/tasks/#{input['id']}", input)  
      },

      output_fields: ->(object_definitions) {
        object_definitions['task']
      }
    },
    
    update_task: {
      description: 'Updated <span class="provider">task</span> in <span class="provider">pivotaltracker</span>',

      input_fields: ->(object_definitions) {
        object_definitions['task'].only('id','project_id','story_id','description').required('id')
      },

      execute: ->(connection, input) {
        put("https://www.pivotaltracker.com/services/v5/projects/#{input['project_id']}/stories/#{input['story_id']}/tasks/#{input['id']}", input)  
      },

      output_fields: ->(object_definitions) {
        object_definitions['task']
      }
    }   
  },
  
  triggers: {
    new_or_updated_story: {
      description: 'New or updated <span class="provider">story</span> in <span class="provider">pivotaltracker</span>',

      type: :paging_desc,

      input_fields: ->() {
        [
          { name: 'project_id', type: :integer, optional: false, hint: 'ID of the project' },
          { name: 'updated_after', type: :timestamp, label: 'since', optional: false }
        ]
      },

      poll: ->(connection, input, last_updated_since) {
        updated_since = (last_updated_since || input['updated_after'] || Time.now).to_time.utc.strftime("%Y-%m-%dT%H:%M:%S")

        response = get("https://www.pivotaltracker.com/services/v5/projects/#{input['project_id']}/stories?created_after=#{updated_since}&updated_after=#{updated_since}")

        next_updated_since = response.last['updated_at'] unless response.blank?

        {
          events: response,
          next_page: last_updated_since,
        }
      },

      document_id: ->(story){
        story['id']
      },
      
      sort_by: ->(story) {
        story['updated_at']
      },

      output_fields: ->(object_definitions) {       
        object_definitions['comment']
      }
  	},
    
    new_comment: {
      description: 'New <span class="provider">comment</span> in <span class="provider">pivotaltracker</span>',

      type: :paging_desc,

      input_fields: ->() {
        [
          { name: 'project_id', type: :integer, optional: false, hint: 'ID of the project' },
          { name: 'story_id', type: :integer, optional: false, hint: 'Id of the story' }
        ]
      },

      poll: ->(connection, input, page) {
        response = get("https://www.pivotaltracker.com/services/v5/projects/#{input['project_id']}/stories/#{input['story_id']}/comments")

        page = response.last['created_at'] unless response.blank?

        {
          events: response.reverse,
          next_page: (response.length >= 100 ? page : nil)
        }
      },

      output_fields: ->(object_definitions) {
        object_definitions['comment']
      }
    },
    
  },
  
  pick_lists: {
    story_type: ->(connection) {
      [
        ["Feature", "feature"],
        ["Bug", "bug"],
        ["Chore", "chore"],
        ["Release", "release"]
      ]
    },

    current_state: ->(connection) {
      [
        ["Accepted", "accepted"],
        ["Delivered", "delivered"],
        ["Finished", "finished"],
        ["Started", "started"],
        ["Rejected", "rejected"],
        ["Planned", "planned"],
        ["Unstarted", "unstarted"],
        ["Unscheduled", "unscheduled"]
      ]
    }
  },
}

