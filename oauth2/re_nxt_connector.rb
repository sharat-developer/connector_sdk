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

      client_id: 'YOUR_RE_NXT_CLIENT_ID',

      client_secret: 'YOUR_RE_NXT_CLIENT_SECRET',

      credentials: ->(connection, access_token) {
        headers('bb-api-subscription-key': "YOUR_BB_API_SUBSCRIPTION_KEY", 'Authorization': "Bearer #{access_token}")
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
    update_constituent: {
      input_fields: ->() {
        [ { name: 'constituent_ID', type: :integer, optional: false },
          { name: 'name', hint: 'For organizations only' },
          { name: 'last', hint: 'Required for individual. All fields change on update.'},
          { name: 'first', hint: 'For individuals only. All fields change on update.'},
          { name: 'middle', hint: 'For individuals only. All fields change on update.'},
          { name: 'preferred_name', hint: 'For individuals only. All fields change on update.' },
          { name: 'title', hint: 'For individuals only. All fields change on update.', control_type: 'select', pick_list: 'title' },
          { name: 'suffix', hint: 'For individuals only. All fields change on update.', control_type: 'select', pick_list: 'suffix' },         
          { name: 'gender', hint: 'For individuals only. All fields change on update.', control_type: 'select', pick_list: [
            ["Male","male"],
            ["Female","female"],
            ["Unknown","unknown"]]},
          { name: "birthdate", hint: 'For individuals only. All fields change on update.', type: :date},
          { name: 'deceased', hint: 'For individuals only. All fields change on update.', control_type: 'select', pick_list: [
            ["true", true],
            ["false", false]]}
        ]
      },

      execute: ->(connection, input) {
        birthdate = input['birthdate'].to_s.split("-")
        if input['name'] != nil
          info = {"name"=>input['name']}
        else
          if (input['last'].present? || input['first'].present? || input['middle'].present? || input['preferred_name'].present? || input['title'].present? || input['suffix'].present? || input['gender'].present? || input['birthdate'].present? || input['deceased'].present?)
            info = {"last"=>input['last'], "first"=>input['first'], "middle"=>input['middle'], "preferred_name"=>input['preferred_name'], "title"=>input['title'], "suffix"=>input['suffix'], "gender"=>input['gender'], "birthdate"=>{"y"=>birthdate[0], "m"=>birthdate[1], "d"=>birthdate[2]}, "deceased"=>input['deceased']}
          else
            info = {}
          end
        end
        patch("https://api.sky.blackbaud.com/constituent/v1/constituents/#{input['constituent_ID']}", info)
      },

      output_fields: ->(object_definitions) {
      }
    },

    search_constituent: {
      input_fields: ->() {
        [ { name: 'search_text', optional: false , hint: "Searches first/middle/last names and email addresses"} ]
      },
      execute: ->(connection, input) {
        {
        'constituents': get("https://api.sky.blackbaud.com/constituent/v1/constituents/search?searchText=#{input['search_text']}")['value']
        }
      },
      output_fields: ->(object_definitions) {
        [{
          name: 'constituents',
          type: :array, of: :object,
          properties: [
            { name: "id", type: :integer},
            { name: "name" },
            { name: "address" },
            { name: "email" }]
        }]
      }
    }
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
  },

  pick_lists: {
    title: ->(connection) {
        get("https://api.sky.blackbaud.com/constituent/v1/titles")['value'].
          map { |title| [title, title] }},
    suffix: ->(connection) {
        get("https://api.sky.blackbaud.com/constituent/v1/suffixes")['value'].
          map { |suffix| [suffix, suffix] }}
  }
}