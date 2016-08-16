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

      credentials: ->(_connection, access_token) {
        headers('bb-api-subscription-key': AppSettings.oauth2.raisers_edge.api_subscription_key,
                'Authorization': "Bearer #{access_token}")
      }
    }
  },

  object_definitions: {

    constituent: {
      fields: ->() {
        [
          { name: "id", hint: "Constituent ID", optional: false },
          { name: "type" },
          { name: "lookup_id" },
          { name: "inactive", type: :boolean },
          { name: 'name', hint: 'For organizations only' },
          { name: 'last', hint: 'Required for individual. All fields change on update.' },
          { name: 'first', hint: 'For individuals only. All fields change on update.' },
          { name: 'middle', hint: 'For individuals only. All fields change on update.' },
          { name: 'preferred_name', hint: 'For individuals only. All fields change on update.' },
          { name: 'title', hint: 'For individuals only. All fields change on update.', control_type: 'select', pick_list: 'title' },
          { name: 'suffix', hint: 'For individuals only. All fields change on update.', control_type: 'select', pick_list: 'suffix' },
          { name: "gender", hint: 'For individuals only. All fields change on update.', control_type: 'select', pick_list: 'gender' },
          { name: "birthdate", type: :date },
          { name: "age", type: :integer },
          { name: "deceased", type: :boolean, hint: 'For individuals only. All fields change on update.' },
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
            { name: "address", control_type: 'email' },
            { name: "do_not_email" },
            { name: "primary", type: :boolean },
            { name: "inactive", type: :boolean }]
          },
          { name: "phone", type: :object, properties: [
            { name: "id" },
            { name: "type", control_type: 'phone' },
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
    }
  },

  actions: {
    update_constituent: {
      description: "Update <span class='provider'>constituent</span> in <span class='provider'>Raiser's Edge NXT</span>",

      input_fields: ->(object_definitions) {
        object_definitions['constituent'].only("id", "name", "last", "first", "middle", "preferred_name",
                                               "suffix", "title", "gender", "birthdate", "deceased")
      },

      execute: ->(_connection, input) {
        if input['birthdate'].present?
          birthdate = input['birthdate'].to_date
          date_hash = {
            'y' => birthdate.year.to_i,
            'm' => birthdate.mon.to_i,
            'd' => birthdate.mday.to_i
          }
          input['birthdate'] = date_hash
        end

        payload = input.reject { |k,v| k == "id" }

        patch("https://api.sky.blackbaud.com/constituent/v1/constituents/#{input['id']}", payload)
      },

      output_fields: ->(_object_definitions) {}
    },

    search_constituent: {
      description: "Search <span class='provider'>constituent</span> in <span class='provider'>Raiser's Edge NXT</span>",

      input_fields: ->(_object_definitions) {
        [
          { name: 'search_text', optional: false, hint: "Searches first/middle/last names and email addresses" }
        ]
      },

      execute: ->(_connection, input) {
        url = "https://api.sky.blackbaud.com/constituent/v1/constituents/search?searchText=#{input['search_text']}"

        {
          'constituents': get(url)['value']
        }
      },

      output_fields: ->(_object_definitions) {
        [
          {
            name: 'constituents', type: :array, of: :object,
            properties: [
              { name: "id", type: :integer },
              { name: "name" },
              { name: "address" },
              { name: "email", control_type: 'email' }
            ]
          }
        ]
      }
    }
  },

  triggers: {

    new_constituent: {
      description: "New <span class='provider'>constituent</span> in <span class='provider'>Raiser's Edge NXT</span>",

      type: :paging_asc,

      input_fields: ->(_object_definitions) {
        [
          {
            name: 'since', type: :timestamp,
            hint: 'Defaults to contituents created after the recipe is first started'
          }
        ]
      },

      poll: ->(_connection, input, link) {
        if link.present?
          response = get(link)
        else
          response = get("https://api.sky.blackbaud.com/constituent/v1/constituents").
                     params(date_added: (input['since'] || Time.now).to_time.utc.iso8601,
                            limit: PAGE_SIZE)
        end

        constituents = response['value'].each do |constituent|
                         birthdate = constituent['birthdate']

                         if birthdate.present?
                           constituent['birthdate'] = Date.new(birthdate['y'], birthdate['m'], birthdate['d'])
                         end
                       end

        {
          events: constituents,
          next_poll: response['next_link'],
          can_poll_more: constituents.length >= PAGE_SIZE
        }
      },

      dedup: ->(constituent) {
        constituent['id']
      },

      output_fields: ->(object_definitions) {
        object_definitions['constituent']
      }
    },

    new_or_updated_constituent: {
      description: "New or Updated <span class='provider'>constituent</span> in <span class='provider'>Raiser's Edge NXT</span>",

      input_fields: ->(_object_definitions) {
        [
          {
            name: 'since', type: :timestamp,
            hint: 'Defaults to contituents created/updated after the recipe is first started'
          }
        ]
      },

      poll: ->(_connection, input, link) {
        if link.present?
          response = get(link)
        else
          response = get("https://api.sky.blackbaud.com/constituent/v1/constituents").
                     params(last_modified: (input['since'] || Time.now).to_time.utc.iso8601,
                            limit: PAGE_SIZE)
        end

        constituents = response['value'].each do |constituent|
                         birthdate = constituent['birthdate']

                         if birthdate.present?
                           constituent['birthdate'] = Date.new(birthdate['y'], birthdate['m'], birthdate['d'])
                         end
                       end

        {
          events: constituents,
          next_poll: response['next_link'],
          can_poll_more: constituents.length >= PAGE_SIZE
        }
      },

      dedup: ->(constituent) {
        (constituent['id']).to_s + '-' + (constituent['date_modified']).to_s
      },

      output_fields: ->(object_definitions) {
        object_definitions['constituent']
      }
    }
  },

  pick_lists: {
    title: ->(_connection) {
      get("https://api.sky.blackbaud.com/constituent/v1/titles")['value'].
        map { |title| [title, title] }
    },

    suffix: ->(_connection) {
      get("https://api.sky.blackbaud.com/constituent/v1/suffixes")['value'].
        map { |suffix| [suffix, suffix] }
    },

    gender: ->(_connection) {
      [
        ["Male", "male"],
        ["Female", "female"],
        ["Unknown", "unknown"]
      ]
    }
  }
}