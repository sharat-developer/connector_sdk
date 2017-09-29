{
  title: "Right Signature",

  connection: {
    fields: [
      {
        name: "api_key",
        label: "Secure Token",
        hint: "You may find API key " \
        "<a href='https://rightsignature.com/oauth_clients'>here</a>",
        control_type: "password",
        optional: false
      }
    ],

    authorization: {
      type: "api_key",

      credentials: lambda { |connection|
        headers(api_token: connection["api_key"])
      }
    }
  },

  object_definitions: {
    document: {
      fields: lambda {
        [
          { name: "guid", label: "Document ID" },
          { name: "created_at", type: "timestamp" },
          { name: "completed_at", type: "timestamp" },
          { name: "last_activity_at", type: "timestamp" },
          { name: "expires_on", type: "timestamp" },
          { name: "is_trashed" },
          { name: "size" },
          { name: "content_type" },
          { name: "original_filename" },
          { name: "signed_pdf_checksum" },
          { name: "subject" },
          { name: "message" },
          { name: "processing_state" },
          { name: "merge_state" },
          { name: "state" },
          { name: "callback_location" },
          { name: "tags" },
          {
            name: "recipients",
            type: "array",
            of: "object",
            properties: [
              { name: "name" },
              { name: "email" },
              { name: "must_sign" },
              { name: "document_role_id" },
              { name: "role_id" },
              { name: "state" },
              { name: "is_sender" },
              { name: "viewed_at" },
              { name: "completed_at" }
            ]
          },
          {
            name: "audit_trails",
            type: "array",
            of: "object",
            properties: [
              { name: "timestamp" },
              { name: "keyword" },
              { name: "message" }
            ]
          },
          {
            name: "pages",
            type: "array",
            of: "object",
            properties: [
              { name: "page_number" },
              { name: "original_template_guid" },
              { name: "original_template_filename" }
            ]
          },
          { name: "original_url" },
          { name: "pdf_url" },
          { name: "thumbnail_url" },
          { name: "large_url" },
          { name: "signed_pdf_url" }
        ]
      }
    }
  },

  test: lambda { |_connection|
    get("https://rightsignature.com/api/documents.json")
  },

  actions: {
    get_document_details: {
      description: "Get <span class='provider'> document details </span>" \
        "by ID in <span class='provider'> RightSignature </span>",
      subtitle: "Get document details by ID",

      input_fields: lambda { |object_definitions|
        object_definitions["document"]
          .only("guid")
          .required("guid")
      },

      execute: lambda { |_connection, input|
        get("https://rightsignature.com/api/documents/#{input['guid']}.json")
          .dig("document")
      },

      output_fields: lambda { |object_definitions|
        object_definitions["document"]
      },

      sample_output: lambda { |_connection|
        get("https://rightsignature.com/api/documents.json")
          .payload(per_page: 1)
          .dig("page", "documents")
          &.first || {}
      }
    }
  },

  triggers: {
    new_signed_document: {
      description: "New <span class='provider'> signed document </span>" \
        "in <span class='provider'> RightSignature </span>",
      subtitle: "New signed document in RightSignature",
      type: "paging_desc",

      input_fields: lambda {
        [
          {
            name: "since",
            label: "From",
            type: "timestamp",
            optional: false
          }
        ]
      },

      poll: lambda { |_connection, input, page|
        page ||= 1
        page_size = 50
        documents = get("https://rightsignature.com/api/documents.json")
                    .payload(page: page,
                             per_page: page_size,
                             state: "completed",
                             sort: "completed")
                    .dig("page", "documents")
                    .select do |document|
                      document["completed_at"].to_time >= input["since"].to_time
                    end

        {
          events: documents,
          next_page: (documents.size >= page_size ? page + 1 : nil)
        }
      },

      document_id: lambda { |document|
        document["guid"]
      },

      sort_by: lambda { |document|
        document["completed_at"]
      },

      output_fields: lambda { |object_definitions|
        object_definitions["document"]
      },

      sample_output: lambda { |_connection|
        get("https://rightsignature.com/api/documents.json")
          .payload(per_page: 1)
          .dig("page", "documents")
          &.first || {}
      }
    }
  }
}
