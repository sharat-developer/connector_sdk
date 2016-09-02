{
  title: 'NewRelic',

  connection: {
    fields: [
      {
        name: 'api_key',
        control_type: 'password',
        label: 'Enter your api key'
      }
    ],

    authorization: {
      type: 'api_key',

      credentials: ->(connection) {
        headers("X-Api-Key": "#{connection['api_key']}")
      }
    }
  },

  test: ->(connection) {
    get("https://api.newrelic.com/v2/applications.json")
  },

  object_definitions: {

    metrics_name: {
      fields: ->() {
        [
          { name: 'metrics', type: :array, of: :object, properties: [
            { name: 'name' },
            { name: 'values', type: :array, of: :object, properties: [] },
          ] }
        ]
      },
    },

    metrics_data: {
      fields: ->() {
        [
          { name: 'metric_data', type: :object, properties: [
            { name: 'from', type: :timestamp },
            { name: 'to', type: :timestamp },
            { name: 'metrics_not_found' },
            { name: 'metrics_found' },
            { name: 'metrics', type: :array, of: :object, properties: [
              { name: 'name' },
              { name: 'timeslices', type: :array, of: :object, properties: [
                { name: 'from', type: :timestamp },
                { name: 'to', type: :timestamp },
                { name: 'values', type: :object, properties: [
                  { name: "average_response_time", type: :integer },
              		{ name: "calls_per_minute", type: :integer },
              		{ name: "call_count", type: :integer },
              		{ name: "min_response_time", type: :integer},
              		{ name: "max_response_time", type: :integer },
              		{ name: "average_exclusive_time", type: :integer },
              		{ name: "average_value", type: :integer },
              		{ name: "total_call_time_per_minute", type: :integer },
              		{ name: "requests_per_minute", type: :integer },
              		{ name: "standard_deviation", type: :integer },
                ] },
              ] },
            ] }
          ] },
        ]
      }
    },
  },

  actions: {

    search_metrics_name: {
      description: 'Search <span class="provider">metrics names</span> in <span class="provider">New Relic</span>',

      input_fields: ->(object_definitions) {
       [
          { name: 'application_id', type: :integer, optional: false },
          { name: 'name', hint: 'Metrics by name' },
          { name: 'page', type: :integer }
        ]
      },

      execute: ->(connection, input) {
        get("https://api.newrelic.com/v2/applications/#{input['application_id']}/metrics.json?#{input}")
       },

      output_fields: ->(object_definitions) {
        object_definitions['metrics_name']
      },

      sample_output: ->(connection) {
        application = get("https://api.newrelic.com/v2/applications.json")['applications'].first['id']
        get("https://api.newrelic.com/v2/applications/#{application}/metrics.json") || []
      }
    },

    search_metrics_data: {
      description: 'Search <span class="provider">metrics data</span> in <span class="provider">New Relic</span>',

      input_fields: ->(object_definitions) {
       [
          { name: 'application_id', type: :integer, optional: false },
          { name: 'names',optional: false, hint: 'Specific metrics by name' },
          { name: 'raw', type: :bolean, hint: 'Return unformatted raw values' },
          { name: 'from', type: :timestamp, hint: 'To retrieve metrics after this time' },
          { name: 'to', type: :timestamp, hint: 'To retrieve metrics before this time' },
          { name: 'values', hint: 'specific metric values' },
          { name: 'period', type: :integer, hint: 'Period of timeslices in seconds' },
          { name: 'summarize', type: :boolean, hint: 'Summarize the data' }
        ]
      },

      execute: ->(connection, input) {
        if input['values'].present?
        	array = input['names'].split(/\n/)
        	name = array.map { |value| "names[]=#{value}"}.join('&')
        	array = input['values'].split(/\n/)
        	value = array.map { |value| "values[]=#{value}"}.join('&')
          query = [name,value].join('&')
          input.delete('values')
          input.delete('names')
        else
          array = input['names'].split(/\n/)
        	query = array.map { |value| "names[]=#{value}"}.join('&')
          input.delete('names')
        end
        get("https://api.newrelic.com/v2/applications/#{input.delete('application_id')}/metrics/data?#{query}",input)
      },

      output_fields: ->(object_definitions) {
        object_definitions['metrics_data']
      },

      sample_output: ->(connection) {
       application = get("https://api.newrelic.com/v2/applications.json")['applications'].first['id']
        name = get("https://api.newrelic.com/v2/applications/#{application}/metrics.json")['metrics'].first['name']
        get("https://api.newrelic.com/v2/applications/#{application}/metrics/data.json").params(names: name) || {}
      }
    }
  },
}
