{
  title: 'bitbucket',

  connection: {
    fields: [   
      { name: "username", optional: false, hint: "Username of owner of the repository", label: "Username" },
      { name: "repo_slug", optional: false, hint: "Repository name", label: "Repository" }
    ],

    authorization: {
      type: 'oauth2',

      authorization_url: ->() {
       'https://bitbucket.org/site/oauth2/authorize?response_type=code&scope=issue:write'
      },

      token_url: ->() {
       'https://bitbucket.org/site/oauth2/access_token?type=refresh'
      },

      client_id: 'HV8cTJ8aLyKC8jucUh',

      client_secret: 'BGHemmMqvXTkPAdCryzTw5GWcw82M8Vx',

      credentials: ->(connection, access_token) {
        headers('Authorization': "Bearer #{access_token}")
      }
    }
  },

  test: ->(connection) {    
    get("https://api.bitbucket.org/2.0/user")
  },

  object_definitions: {   
    issue: {
      fields: ->() {
        [
          { name: "title", optional: false },
          { name: "description" },
          { name: "priority", optional: false, control_type: :select, pick_list: "priority", hint: 'Select priority' },
          { name: "kind", optional: false, control_type: :select, pick_list: "kind", hint: 'Type of issue' },
          { name: "repository", type: :object, properties:[
            { name: "links", type: :object, properties: [
              { name: "self", type: :object, properties: [
                { name: "href", type: :url }
              ]},
              { name: "html", type: :object, properties: [
                { name: "href", type: :url }
              ]},
              { name: "avatar", type: :object, properties: [
                { name: "href", type: :url }
              ]},
            ]},
            { name: "type" },
            { name: "name" },
            { name: "full_name" },
            { name: "uuid" }
          ]},
          { name: "links", type: :object, properties: [
            { name: "self", type: :object, properties: [
              { name: "href", type: :url }
            ]}
          ]},
          { name: "reporter", type: :object, properties: [
            { name: "username" },
            { name: "display_name" },
            { name: "type" },
            { name: "uuid" },
            { name: "links", type: :object, properties: [
              { name: "self", type: :object, properties: [
                { name: "href", type: :url }
              ]},
              { name: "html", type: :object, properties: [
                { name: "href", type: :url }
              ]},
              { name: "avatar", type: :object, properties: [
                { name: "href", type: :url }
              ]},
            ]},
          ]},
          { name: "component" },
          { name: "votes", type: :integer },
          { name: "watches", type: :integer },
          { name: "content", type: :object, properties: [
            { name: "raw" },
            { name: "markup", control_type: :select, pick_list: "markup" },
            { name: "html" }
          ]},
          { name: "assignee", type: :object, properties: [
            { name: "username" },
            { name: "display_name" },
            { name: "type" },
            { name: "uuid" },
            { name: "links", type: :object, properties: [
              { name: "self", type: :object, properties: [
                { name: "href", type: :url }
              ]},
              { name: "html", type: :object, properties: [
                { name: "href", type: :url }
              ]},
              { name: "avatar", type: :object, properties: [
                { name: "href", type: :url }
              ]},
            ]},
          ]},
          { name: "status", control_type: :select, pick_list: "state" },
          { name: "version" },
          { name: "edited_on", type: :datetime },
          { name: "created_on", type: :datetime },
          { name: "milestone" },
          { name: "update_on", type: :datetime },
          { name: "type" },
          { name: "id", type: :integer },
          { name: "links", type: :object, properties: [
            { name: "self", type: :object, properties: [
              { name: "href", type: :url }
            ]},
            { name: "repositories", type: :object, properties: [
              { name: "href", type: :url }
            ]},
            { name: "html", type: :object, properties: [
              { name: "href", type: :url }
            ]},
            { name: "followers", type: :object, properties: [
              { name: "href", type: :url }
            ]},
            { name: "avatar", type: :object, properties: [
              { name: "href", type: :url }
            ]},
            { name: "following", type: :object, properties: [
              { name: "href", type: :url }
            ]}
          ]}
        ]
      }
    }
  },
  
  actions: {
    create_issue: {
      description: 'Create <span class="provider">Issue</span> in <span class="provider">Bitbucket</span>',

      input_fields: ->(object_definitions) {
        object_definitions['issue'].only('title','priority','kind')
      },

      execute: ->(connection,input) {
        post("https://api.bitbucket.org/2.0/repositories/#{connection['username']}/#{connection['repo_slug'].gsub(/[ ]/,'-')}/issues",input)
      },

      output_fields: ->(object_definitions) {
        object_definitions['issue']
      }
    },
    
    search_issue: {
      description: 'Search <span class="provider">Issue</span> in <span class="provider">Bitbucket</span>',

      input_fields: ->(object_definitions) {
        [
          { name: "id", type: :integer, hint: 'Search using issue ID' },
          { name: "title", hint: 'Search using title' },
          { name: "kind", hint: 'Search using kind' },
          { name: "priority", hint: 'Search using priority' },
          { name: "status", hint: 'Search using status' }
        ]
      },

      execute: ->(connection,input) {
        c = input.map do |k,v|
              "#{k}=#{v}"
            end.join("&")

        get("https://api.bitbucket.org/1.0/repositories/#{connection['username']}/#{connection['repo_slug'].gsub(/[ ]/,'-')}}/issues?#{c}")
      },

      output_fields: ->(object_definitions) {
        object_definitions['issue']
      }
    },
    
    list_comments_in_an_issue_by_issue_id: {
      description: 'List <span class="provider">Comments</span> in an Issue in <span class="provider">Bitbucket</span>',

      input_fields: ->(object_definitions) {
        [
          { name: "issue_id", type: :integer, optional: false }
        ]
      },

      execute: ->(connection,input) {
        get("https://api.bitbucket.org/2.0/repositories/#{connection['username']}/#{connection['repo_slug'].gsub(/[ ]/,'-')}}/issues/#{input['issue_id']}/comments")
      },

      output_fields: ->(object_definitions) {
        object_definitions['issue']
      }
    },
  },
  
  triggers: {
    new_or_updated_issue: {
      description: 'New or updated <span class="provider">issue</span> in <span class="provider">Bitbucket</span>',

      type: :paging_desc,

      input_fields: ->() {
        [
          { name: 'since', type: :timestamp }
        ]
      },

      poll: ->(connection, input, next_page) {
        if next_page.present?
          page = next_page[0]
          updated_date = next_page[1]
        end

        if page.present?
          response = get(page)
        else
          updated_since = (updated_date || input['since'] || Time.now).to_time.utc.strftime("%Y-%m-%dT%H:%M:%S")
          response = get("https://api.bitbucket.org/2.0/repositories/#{connection['username']}/#{connection['repo_slug'].gsub(/[ ]/,'-')}}/issues?q=updated_on>#{updated_since}&sort=-updated_on")
        end

        next_updated_since = response['values'].last['updated_on'] unless response['values'].blank?   

        {
          events: response['values'],
          next_page: [response['next'], Time.now]
        }
      },

      document_id: ->(issue){
        issue['document_id']
      },

      sort_by: ->(issue) {
        issue['updated_on']
      },

      output_fields: ->(object_definitions) {
        object_definitions['issue']
      }
    }, 
  },
  
  pick_lists: {
    markup: ->(connection) {
      [
        ["markdown", "markdown"],
        ["creole", "creole"]
      ]
    },

    kind: ->(connection) {
      [
        ["bug", "bug"],
        ["enhancement", "enhancement"],
        ["proposal", "proposal"],
        ["task", "task"]
      ]
    },

    scm: ->(connection) {
      [
        ["hg", "hg"],
        ["git", "git"]
      ]
    },

    fork_policy: ->(connection) {
      [
        ["allow_forks", "allow_forks"],
        ["no_public_forks", "no_public_forks"],
        ["no_forks", "no_forks"]
      ]
    },

    priority: ->(connection) {
      [
        ["trivial", "trivial"],
        ["minor", "minor"],
        ["major", "major"],
        ["critical", "critical"],
        ["blocker", "blocker"]
      ]
    },

    state: ->(connection) {
      [
        ["new", "new"],
        ["open", "open"],
        ["resolved", "resolved"],
        ["on hold", "on hold"],
        ["invalid", "invalid"],
        ["duplicate", "duplicate"],
        ["wontfix", "wontfix"],
        ["closed", "closed"]
      ]
    },
  }
}
