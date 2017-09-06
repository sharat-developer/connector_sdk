{
  title: 'Mandrill',
  
  connection: {
    fields: [
      {
        name: 'api_key',
        label: 'API Key',
        control_type: 'password',
        hint: "You may find it in <a href='https://mandrillapp.com//settings'>here</a>",
        optional: false,
      }
    ],
    
    authorization: {
      type: 'api_key',
      
      credentials: ->(connection) {
        payload(key: connection['api_key'])
      },
    }
  },
  
  test: ->(connection) {
    post("https://mandrillapp.com/api/1.0/templates/list.json")
  },
  
  object_definitions: {
    send_template_input: {
      fields: ->(connection, config_fields) {
        template_variables = (config_fields.blank?) ? ([]) : (
        post("https://mandrillapp.com/api/1.0/templates/info.json", name: config_fields["template"])["code"]
        .scan(/mc:edit=\"([^\"]*)\"/)
        .map { |var|
          {
            name: var.first,
            hint: "Include html tags for better formatting"
          }
        }
        )
        
        [
          {
            name: "from_email",
            hint: "The default sender address for the template, if provided - draft version",
            optional: false,
          },
          {
            name: "from_name",
            hint: "The default sender from name for the template, if provided - draft version",
          },
          {
            name: "to",
            hint: "List of email recipients, one per line.",
            optional: false,
          },
          {
            name: "important",
            hint: "Whether or not this message is important, and should be delivered ahead of non-important messages",
            type: "boolean",
          },
          {
            name: "track_opens",
            hint: "Whether or not to turn on open tracking for the message",
            type: "boolean"
          },
          {
            name: "track_clicks",
            hint: "Whether or not to turn on click tracking for the message",
            type: "boolean"
          },
          {
            name: "send_at",
            hint: "When this message should be sent as a UTC timestamp in YYYY-MM-DD HH:MM:SS format. If you specify a time in the past, the message will be sent immediately. Note: An additional fee applies for scheduled email, and this feature is only available to accounts with a positive balance.",
            type: "timestamp",
          }
        ].concat(
        if template_variables.blank?
          []
        else
          [
            {
              name: "template_content",
              type: "object",
              properties: template_variables
            }
          ]
        end
        )
      }
    },
  },
  
  
  actions: {
    create_message_from_template: {
      description: 'Create <span class="provider">message from template</span> in <span class="provider">Mandrill</span>',
      
      config_fields: [
        {
          name: "template",
          control_type: "select",
          pick_list: "templates",
          optional: false,
        },
      ],
      
      input_fields: ->(object_definitions) {
        object_definitions["send_template_input"]
      },
      
      execute: ->(connection, input) {
        message = {
          "from_email" => input['from_email'],
          "from_name" => input['from_name'],
          "to" => input['to']
          .split("\n")
          .map { |to| { email: to.strip } },
          "important" => input['important'],
          "track_opens" => input['track_opens'],
          "track_clicks" => input['track_clicks']
        }
        
        post("https://mandrillapp.com/api/1.0/messages/send-template.json")
        .payload(
        template_name: input['template'],
        template_content: (
        input['template_content'] || []
        )
        .map { |k,v| { name: k, content: v } },
        message: message,
        send_at: input['send_at']
        )
        &.first
      },
      
      output_fields: ->(object_definitions) {
        [
          { name: 'email' },
          { name: 'status' },
          { name: '_id' },
          { name: 'reject_reason' }
        ]
      },
      
      sample_output: ->() {
        {
          email: "eeshan@workato.com",
          status: "send",
          _id: "abc123abc123abc123abc123abc123",
          reject_reason: "hard-bounce",
        }
      },
    },
  },
  
  pick_lists: {
    templates: ->(connection) {
      post("https://mandrillapp.com/api/1.0/templates/list.json")
      .map { |template| [template['name'], template['slug']] }
    },
  },
}
