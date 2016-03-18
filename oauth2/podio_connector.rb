# Substitute YOUR_PODIO_CLIENT_ID for your OAuth2 client id from Podio
# Substitute YOUR_PODIO_CLIENT_SECRET for your OAuth2 client secret from Podio
{
  title: 'Podio',

  connection: {
    authorization: {
      type: 'oauth2',

      authorization_url: ->() {
        'https://podio.com/oauth/authorize'
      },

      token_url: ->() {
        'https://podio.com/oauth/token'
      },

      client_id: 'YOUR_PODIO_CLIENT_ID',

      client_secret: 'YOUR_PODIO_CLIENT_SECRET',

      credentials: ->(connection, access_token) {
        headers('Authorization': "OAuth2 #{access_token}")
      }
    }
  },

  object_definitions: {
    contact: {
      # Provide a preview user to display in the recipe data tree.
      preview: ->(connection) {
        get("https://api.podio.com/contact.json?limit=1").first
      },

      fields: ->() {
        [
          { 'name': 'profile_id'},
          { 'name': 'name' },
          { 'name': 'organization' },
          { 'name': 'department' },
          { 'name': 'skype' },
          { 'name': 'about' },
          { 'name': 'address' },
          { 'name': 'zip' },
          { 'name': 'city' },
          { 'name': 'state' },
          { 'name': 'country' },
          { 'name': 'mail' },
          { 'name': 'phone' },
          { 'name': 'title' },
          { 'name': 'linkedin' },
          { 'name': 'url' },
          { 'name': 'twitter' }
        ]
      },
  },
  },
  actions: {
    get_contacts: {
      input_fields: ->(object_definitions) {
        []
      },

      execute: ->(connection, input) {
        { contacts: get("https://api.podio.com/contact/?limit=5") }
      },

      # Output schema.  Same as input above.
      output_fields: ->(object_definitions) {
        [ 
          { name: 'contacts', type: 'array', of: 'object', properties: object_definitions['contact'] }
      	]
      }
    },
  },
}
