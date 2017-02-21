{
  title: 'Docparser',

  # HTTP basic auth example.
  connection: {
    fields: [
      {
        name: 'api_key',
        label: 'Docparser Account API Key',
        optional: false,
        hint: 'Enter your secret Docparser API key. You can find your API key inside your Docparser account or in the settings of your Document Parser.'
      }
    ],

    authorization: {
      type: 'basic_auth',
      credentials: lambda do |connection|
        user(connection['api_key'])
        password("")
      end
    }
  },
  
  pick_lists: {
  	parsers: lambda do |connection|
    	get("https://api.docparser.com/v1/parsers").
      	map { |parser| [parser["label"], parser["id"]] }
	  	end
	},

  object_definitions: {
    document: {
    	fields: lambda do
      	[
        	{ name: "id", label: "Document Id"},
      	]
    	end
  	},
  	parsed_data: {
    	fields: lambda do |connection, config_fields|
      	get("https://api.docparser.com/v1/results/#{config_fields['parser_id']}/schema")
    	end
  	}
	},
  
  test: lambda do |connection|
  	get("https://api.docparser.com/v1/ping")["msg"].present?
	end,
  
  triggers: {
	  parsed_data: {
    	config_fields: [
      	{
        	name: "parser_id",
        	label: "Document Parser",
        	control_type: :select,
        	pick_list: "parsers",
        	optional: false
      	}
    	],
      poll: lambda do |connection, input, last_created_since|
      	parsed_data = get("https://api.docparser.com/v1/results/#{input['parser_id']}")
      	{
        	events: parsed_data
      	}
    	end,
      webhook_subscribe: lambda do |webhook_url, connection, input, recipe_id|
      	post("https://api.docparser.com/v1/webhook/subscribe/#{input['parser_id']}/workato",
           target_url: webhook_url,
           webhook_token: recipe_id)
    	end,
      webhook_unsubscribe: lambda do |webhook, connection|
        post("https://api.docparser.com/v1/webhook/unsubscribe/#{webhook['parser_id']}/workato",
           id: webhook['webhook_id'])
	    end,
      webhook_notification: lambda do |input, payload|
      	payload
	    end,
      dedup: lambda do |parsed_data| 
      	parsed_data["id"]
   	  end,
    	output_fields: lambda do |object_definitions|
      	object_definitions["parsed_data"]
    	end
  	}
	},
  
  actions: {
  	fetch_document_from_url: {
    	input_fields: lambda do
      	[
        	{ 
            name: "url", 
            label: "Source URL",
            hint: "Upload file from this URL",
            optional: false 
          },
          {
        		name: "parser_id",
        		label: "Document Parser",
            hint: "The Document Parser the file gets imported to",
        		control_type: :select,
        		pick_list: "parsers",
        		optional: false
      		}
      	]
    	end,
    	execute: lambda do |connection, input|
      	post("https://api.docparser.com/v1/document/fetch/#{input["parser_id"]}?url=#{input["url"]}")
    	end,
    	output_fields: lambda do |object_definitions|
      	object_definitions["document"]
    	end
  	}
	}
}