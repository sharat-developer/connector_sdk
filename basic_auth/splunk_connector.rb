{
  title: "Splunk",
  secure_tunnel: true,

  connection: {
    fields: [
      {
        name: "server_url",
        label: "Server URL",
        control_type: "text",
        hint: "The URL of the Splunk management port (e.g. https://yourdomain:8089). You MUST install the <a href=\"https://splunkbase.splunk.com/apps/#/search/workato\">Workato Add-on for Splunk</a> first."
      },
      {
        name: "username",
        hint: "The Splunk username (e.g. admin)"
      },
      {
        name: "password",
        control_type: "password",
        hint: "The password for the Splunk username"
      }
    ],
    authorization: {
      type: "basic_auth",
      credentials: ->(connection) {
        user(connection["username"])
        password(connection["password"])
      }
    }
  },

  test: ->(connection) {
    get("#{connection['server_url']}/services/workato/version")
  },

  object_definitions: {
    generic_alert: {
      fields: ->(connection, config_fields) {
        config_fields["fields"].split(",").map { |name| { name: name.strip }}
      }
    },
    service_alert: {
      fields: ->(connection, config_fields) {
        [
          { name: "event_id", type: :string, optional: false },
          { name: "severity", type: :string },
          { name: "title", type: :string },
          { name: "_time", type: :integer, optional: false },
          { name: "severity_label", type: :string },
          { name: "description", type: :string },
        ]
      }
    },
  },

  triggers: {
    new_generic_alert: {
      input_fields: ->(object_definitions) {
        [
          {
            name: "search_name",
            label: "Splunk alert",
            type: :string,
            control_type: :select,
            pick_list: "saved_searches",
            optional: false,
            hint: "Select one of the alerts saved in Splunk that have the Workato alert action assigned.",
          }
        ]
      },

      config_fields: [
        {
          name: "fields",
          label: "Alert fields",
          type: :string,
          optional: false,
          hint: "Comma-separated field names to be taken over from the Splunk data (e.g. host, count)",
        }
      ],

      webhook_subscribe: ->(callback_url, connection, input, flow_id) {
        data = post(
          "#{connection['server_url']}/services/workato/alerts",
          callback_url: callback_url,
          search_name: input["search_name"]
        )

        {
          server_url: connection["server_url"],
          search_name: data["search_name"],
          callback_url: data["callback_url"],
        }
      },

      webhook_unsubscribe: ->(subscription) {
        delete(
          "#{subscription["server_url"]}/services/workato/alerts",
          search_name: subscription["search_name"],
          callback_url: subscription["callback_url"]
        )
      },

      webhook_notification: ->(input, payload) {
        payload
      },

      dedup: ->(event) {
        rand()
      },

      output_fields: ->(object_definitions) {
        object_definitions["generic_alert"]
      },
    },

    new_service_alert: {
      webhook_subscribe: ->(callback_url, connection, input, flow_id) {
        data = post(
          "#{connection['server_url']}/services/workato/servicealerts",
          callback_url: callback_url
        )

        {
          server_url: connection["server_url"],
          search_name: data["search_name"],
          callback_url: data["callback_url"],
        }
      },

      webhook_unsubscribe: ->(subscription) {
        delete(
          "#{subscription['server_url']}/services/workato/servicealerts",
          search_name: subscription["search_name"],
          callback_url: subscription["callback_url"]
        )
      },

      webhook_notification: ->(input, payload) {
        payload
      },

      dedup: ->(event) {
        event["event_id"]
      },

      output_fields: ->(object_definitions) {
        object_definitions["service_alert"]
      },
    },
  },

  pick_lists: {
    saved_searches: ->(connection) {
      get("#{connection['server_url']}/services/workato/alerts").
        map { |name| [name,name] }
    }
  }
}
