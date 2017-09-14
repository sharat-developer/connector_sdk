{
  title: 'Google BigQuery',

  connection: {
    fields: [
      {
        name: "client_id",
        hint: "Find it in <a href='https://console.cloud.google.com/apis/credentials'>here</a>",
        optional: false,
      },
      {
        name: "client_secret",
        hint: "Find it in <a href='https://console.cloud.google.com/apis/credentials'>here</a>",
        optional: false,
        control_type: "password",
      }
    ],

    authorization: {
      type: 'oauth2',

      authorization_url: ->(connection) {
        scopes = [
          "https://www.googleapis.com/auth/bigquery",	#View and manage your data in Google BigQuery
          "https://www.googleapis.com/auth/bigquery.insertdata",	#Insert data into Google BigQuery
          "https://www.googleapis.com/auth/cloud-platform",		#View and manage your data across Google Cloud Platform services
          "https://www.googleapis.com/auth/cloud-platform.read-only",	#View your data across Google Cloud Platform services
          "https://www.googleapis.com/auth/devstorage.full_control",	#Manage your data and permissions in Google Cloud Storage
          "https://www.googleapis.com/auth/devstorage.read_only",	#View your data in Google Cloud Storage
          "https://www.googleapis.com/auth/devstorage.read_write",	#Manage your data in Google Cloud Storage
        ].join(" ")

        "https://accounts.google.com/o/oauth2/auth?client_id=#{connection["client_id"]}&response_type=code&scope=#{scopes}&access_type=offline&include_granted_scopes=true&prompt=consent"
      },

      acquire: ->(connection, auth_code, redirect_uri) {
        response = post("https://accounts.google.com/o/oauth2/token")
        .payload(
        client_id: connection["client_id"],
        client_secret: connection["client_secret"],
        grant_type: 'authorization_code',
        code: auth_code,
        redirect_uri: redirect_uri,
        )
        .request_format_www_form_urlencoded

        [
          {
            access_token: response['access_token'],
            refresh_token: response['refresh_token'],
          },
          nil,
          nil,
        ]
      },

      refresh: ->(connection, refresh_token) {
        post("https://accounts.google.com/o/oauth2/token")
        .payload(
        client_id: connection["client_id"],
        client_secret: connection["client_secret"],
        grant_type: 'refresh_token',
        refresh_token: refresh_token,
        )
        .request_format_www_form_urlencoded
      },

      refresh_on: [401],

      apply: ->(connection, access_token) {
        headers(Authorization: "Bearer #{access_token}")
      },
    },
  },

  test: ->(connection) {
    get("https://www.googleapis.com/bigquery/v2/projects")
    .params(maxResults: 1)
  },

  object_definitions: {
    table_schema: {
      fields: ->(connection, config_fields) {
        project_id = config_fields['project']
        dataset_id = config_fields['dataset']
        table_id = config_fields['table']

        table_fields = if (project_id && dataset_id && table_id)
          get(
          "https://www.googleapis.com/bigquery/v2/projects/#{project_id}/datasets/#{dataset_id}/tables/#{table_id}"
          )
          .dig("schema", "fields")
        else
          []
        end

        type = {
          "BYTES" => "string",
          "INTEGER" => "integer", "INT64" => "integer",
          "FLOAT" => "number", "FLOAT64" => "number",
          "BOOLEAN" => "boolean", "BOOL" => "boolean",
          "TIMESTAMP" => "timestamp",
          "DATE" => "date",
          "TIME" => "string",
          "DATETIME" => "string",
          "RECORD" => "object", "STRUCT" => "object",
        }

        hint = {
          "STRING" => " | Variable-length character (UTF-8) data.",
          "BYTES" => " | Variable-length binary data.",
          "INTEGER" => " | 64-bit signed integer.",
          "FLOAT" => " | Double-precision floating-point format.",
          "BOOLEAN" => " | Boolean values are represented by the keywords true and false (case insensitive). Example: true",
          "TIMESTAMP" => " | Represents an absolute point in time, with microsecond precision. Example: 9999-12-31 23:59:59.999999 UTC",
          "DATE" => " | Represents a logical calendar date. Example: 2017-09-13",
          "TIME" => " | Represents a time, independent of a specific date. Example: 11:16:00.000000",
          "DATETIME" => " | Represents a year, month, day, hour, minute, second, and subsecond. Example: 2017-09-13T11:16:00.000000",
          "RECORD" => " | A collection of one or more other fields.", #info - https://cloud.google.com/bigquery/data-types
        }

        get_field_name = ->(field) {
          field["name"].downcase
        }

        get_field_hint = ->(field) {
          (field["description"] && hint[field["type"]]) ? (field["description"] + hint[field["type"]]) : (field["description"] || hint[field["type"]])
        }

        get_field_type = ->(field) {
          type[field["type"]]
        }

        get_field_optional = ->(field) {
          (field["mode"] != "REQUIRED")
        }

        #todo
        # get_field_control_type = ->(field) {
        #   (field["type"] == "BOOLEAN") ? ("checkbox") : ("text")
        # }

        build_schema_field = ->(field) {
          if ["RECORD", "STRUCT"].include? field["type"]
            {
              name: get_field_name[field],
              hint: get_field_hint[field],
              optional: get_field_optional[field],
              type: get_field_type[field],
              properties: field["fields"]
              .map {|inner_field|
                build_schema_field[inner_field]
              }
            }
          else
            {
              name: get_field_name[field],
              hint: get_field_hint[field],
              optional: get_field_optional[field],
              type: get_field_type[field],
            }
          end
        }

        table_schema_fields = [
          {
            name: "insertId",
            hint: "A unique ID for each row. BigQuery uses this property to detect duplicate insertion requests on a best-effort basis"
          }
        ]
        .concat(table_fields.map { |table_field|
          build_schema_field[table_field]
        }
        )

        [
          name: "rows",
          optional: false,
          hint: "A JSON object that contains a row of data. The object's properties and values must match the destination table's schema",
          type: "array",
          of: "object",
          properties: table_schema_fields
        ]
      },
    },
  },

  actions: {
    add_rows: {
      description: 'Add <span class="provider">rows to dataset</span> in <span class="provider">BigQuery</span>',
      subtitle: "Add data rows",
      help: "Streaming Data into BigQuery, you can choose to stream your data into BigQuery using this method.",

      config_fields:
      [
        {
          name: "project",
          hint: "Select the appropriate Project to import data",
          optional: false,
          control_type: "select",
          pick_list: "projects",
        },
        {
          name: "dataset",
          control_type: "select",
          pick_list: "datasets",
          pick_list_params: { project_id: "project" },
          optional: false,
          hint: "Select a dataset to view list of tables",
        },
        {
          name: "table",
          control_type: "select",
          pick_list: "tables",
          pick_list_params: { project_id: "project", dataset_id: "dataset" },
          optional: false,
          hint: "Select a table to stream data",
        },
      ],

      input_fields: ->(object_definitions) {
        object_definitions["table_schema"]
      },

      execute: ->(connection, input) {
        project_id = input["project"]
        dataset_id = input["dataset"]
        table_id = input["table"]
        rows = input["rows"] || []

        payload = {
          "rows" =>	rows.map { |row|
            insert_id = row.delete("insertId") || ""  # remove insertId from json part of input data
            {
              "insertId": insert_id,
              "json" => row
            }
          }
        }

        response = post(
          "https://www.googleapis.com/bigquery/v2/projects/#{project_id}/datasets/#{dataset_id}/tables/#{table_id}/insertAll"
          )
        .params(fields: "insertErrors,kind")
        .payload(payload)
      },

      output_fields: ->(object_definitions) {
        [
          { name:"kind" },
          {
            name:"insertErrors",
            type: "array",
            of: "object",
            properties: [
              { name:"index" },
              {
                name:"errors",
                type: "array",
                of: "object",
                properties: [
                  { name:"reason" },
                  { name:"location" },
                  { name:"debugInfo" },
                  { name:"message" },
                ],
              },
            ],
          },
        ]
      },

      sample_output: ->() {
        {
          kind: "bigquery#tableDataInsertAllResponse",
          insertErrors: [
            {
              index: 0,
              errors: [
                {
                  reason: "invalid",
                  location: "name1",
                  debugInfo: "generic::not_found: no such field.",
                  message: "no such field.",
                },
              ],
            },
          ],
        }
      },
    },
  },

  triggers: {
  },

  pick_lists: {
    projects: ->(connection) {
      get("https://www.googleapis.com/bigquery/v2/projects")["projects"]
      .map { |project| [project["friendlyName"], project["id"]]}
    },

    datasets: ->(connection, project_id:) {
      get("https://www.googleapis.com/bigquery/v2/projects/#{project_id}/datasets")["datasets"]
      .map { |dataset| [dataset["datasetReference"]["datasetId"], dataset["datasetReference"]["datasetId"]]}
    },

    tables: ->(connection, project_id:, dataset_id:) {
      get("https://www.googleapis.com/bigquery/v2/projects/#{project_id}/datasets/#{dataset_id}/tables")["tables"]
      .map { |table| [table["tableReference"]["tableId"], table["tableReference"]["tableId"]]}
    },
  },
}
