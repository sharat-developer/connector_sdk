{
  title: 'Confluence',

  connection: {
    fields: [
      {
        name: 'subdomain',
        control_type: 'subdomain',
        url: '.atlassian.net',
        hint: 'Your jira servicedesk name as found in your jira servicedesk URL'
      },
      {
        name: 'username',
        optional: true,
        hint: 'Your user name (not email)'
      },
      {
        name: 'password',
        control_type: 'password'
      }
    ],

    authorization: {
      type: 'basic_auth',
      credentials: ->(connection) {
        user(connection['username'])
        password(connection['password'])
      }
    }
  },

  test: ->(connection) {
    get("https://#{connection['subdomain']}.atlassian.net/wiki/rest/api/group")
  },

  object_definitions: {
    page: {
      fields: ->() {
        [
        ]
      }
    }
  },

  actions: {
    search_pages: {
      description: 'Search for <span class="provider">pages</span> in <span class="provider">Confluence</span>',
      
      input_fields: ->() {
        [
          { name: 'text', optional: false },
          { name: 'space' }
        ]
      },
      
      execute: ->(connection, input) {
        cql = "text ~ \"#{input['text']}\" AND type = page"
        cql = cql + " AND space = \"#{input['space']}\"" if input['space'].present?
        get("https://#{connection['subdomain']}.atlassian.net/wiki/rest/api/search").params(cql: cql)
      },

      output_fields: ->() {
        [
          {
            name: 'results',
            type: 'array',
            properties: [
              { name: 'title' },
              { name: 'excerpt' },
              { name: 'url' },
              { name: 'lastModified', type: 'timestamp' },
              { name: 'friendlyLastModified' }
            ]
          }
        ]
      }
    },

    create_page: {
      description: 'Create <span class="provider">page</span> in <span class="provider">Confluence</span>',
      
      input_fields: ->() {
        [
          { name: 'space', optional: false },
          { name: 'title', optional: false },
          { name: 'body', optional: false },
        ]
      },
      
      execute: ->(connection, input) {
        post("https://#{connection['subdomain']}.atlassian.net/wiki/rest/api/content").
          payload(type: 'page',
                  title: input['title'],
                  space: {
                    key: input['space']
                  },
                  body: {
                    storage: {
                      value: input['body'],
                      representation: 'storage'
                    }
                  })
      }
    }
  },
}
