{
  title: "Raiser's Edge",

  connection: {
    authorization: {
      type: 'oauth2',

      authorization_url: ->() {
        'https://oauth2.sky.blackbaud.com/authorization?response_type=code'
      },

      token_url: ->() {
        'https://oauth2.sky.blackbaud.com/token'
      },

      client_id: 'e7be131e-7c9f-4950-98c2-35c39fe5e131',

      client_secret: 'V+0qg8Pm5DTVT000GowrdCJhEwsVJ5wAxQys6RFNulc=',

      credentials: ->(connection, access_token) {
        headers('bb-api-subscription-key': "b0038b5e982d4d449e3436a427b81e0f", 'Authorization': "Bearer #{access_token}")
      }
    }
  },
  
  object_definitions: {

    constituent: {
      fields: ->() {
        [
          { name: "id" },
          { name: "type" },
          { name: "lookup_id" },
          { name: "inactive", type: :boolean },
          { name: "name" },
          { name: "last" },
          { name: "first" },
          { name: "middle" },
          { name: "preferred_name" },
          { name: "title" },
          { name: "gender" },
          { name: "birthdate", type: :object, properties: [
            { name: "y", type: :integer },
            { name: "m", type: :integer },
            { name: "d", type: :integer }]
          },
          { name: "age", type: :integer },
          { name: "deceased", type: :boolean },
          { name: "address", type: :object, properties: [
            { name: "id" },
            { name: "constituent_id" },
            { name: "type" },
            { name: "formatted_address" },
            { name: "preferred" },
            { name: "do_not_mail" },
            { name: "address_lines" },
            { name: "city" },
            { name: "state" },
            { name: "postal_code" },
            { name: "county" },
            { name: "country" }]
          },
          { name: "email", type: :object, properties: [
            { name: "id" },
            { name: "type" },
            { name: "address" },
            { name: "do_not_email" },
            { name: "primary", type: :boolean },
            { name: "inactive", type: :boolean }]
          },
          { name: "phone", type: :object, properties: [
            { name: "id" },
            { name: "type" },
            { name: "number" },
            { name: "do_not_call", type: :boolean },
            { name: "primary", type: :boolean },
            { name: "inactive", type: :boolean }]
          },
          { name: "online_presence", type: :object, properties: [
            { name: "id" },
            { name: "type" },
            { name: "address" },
            { name: "primary", type: :boolean },
            { name: "inactive", type: :boolean }]
          },
          { name: "spouse", type: :object, properties: [
            { name: "id" },
            { name: "last" },
            { name: "first" }]
          },
          { name: "date_added" },
          { name: "date_modified" },
        ]
      }
    },
    email: {
        fields: ->() {
          [
            { name: "id" },
            { name: "constituent_id" },
            { name: "type" },
            { name: "address" },
            { name: "do_not_email", type: :boolean },
            { name: "primary", type: :boolean },
            { name: "inactive", type: :boolean }]
        }
    },
     
    phone: {
        fields: ->() {
          [
            { name: "id" },
            { name: "constituent_id" },
            { name: "type" },
            { name: "number" },
            { name: "do_not_call", type: :boolean },
            { name: "primary", type: :boolean },
            { name: "inactive", type: :boolean }]
        }
    },
    address: {
        fields: ->() {
          [
            { name: "id" },
            { name: "constituent_id" },
            { name: "type" },
            { name: "formatted_address" },
            { name: "preferred", type: :boolean },
            { name: "do_not_mail", type: :boolean },
            { name: "address_lines" },
            { name: "city" },
            { name: "state" },
            { name: "postal_code" },
            { name: "country" }]
        }
    },
  },

  actions: {
  },
  
  triggers: {
    
    new_constituent: {
      type: :paging_asc,

      input_fields: ->() {
        [{
            name: 'since', type: :timestamp,
            hint: 'Defaults to contituents created/updated after the recipe is first started'
        }]
      },
      
      poll: ->(connection, input, link) {
        if link != nil
          response = get(link)
        else
          params = {
            'date_added' => (input['since'] || Time.now).to_time.utc.iso8601
          }
          response = get("https://api.sky.blackbaud.com/constituent/v1/constituents", params)
        end
        {
          events: response['value'],
          next_poll: response['next_link'],
        }
      },

      dedup: ->(constituent) {
        (constituent['id']).to_s + '-' + (constituent['date_added']).to_s
      },

      output_fields: ->(object_definitions) {
        object_definitions['constituent']
      }
    },
    
    new_or_updated_constituent: {
      type: :paging_asc,

      input_fields: ->() {
        [{
            name: 'since', type: :timestamp,
            hint: 'Defaults to contituents created/updated after the recipe is first started'
        }]
      },
      
      poll: ->(connection, input, link) {
        if link != nil
          response = get(link)
        else
          params = {
            'last_modified' => (input['since'] || Time.now).to_time.utc.iso8601
          }
          response = get("https://api.sky.blackbaud.com/constituent/v1/constituents", params)
        end
        {
          events: response['value'],
          next_poll: response['next_link'],
        }
      },

      dedup: ->(constituent) {
        (constituent['id']).to_s + '-' + (constituent['date_modified']).to_s
      },

      output_fields: ->(object_definitions) {
        object_definitions['constituent']
      }
    },
  }
}