{
  title: 'workfront',

  connection: {
    fields: [
      { name: 'subdomain',
        control_type: 'subdomain',
        url: '.workfront.com',
        optional: false,
        hint: 'Your workfront Subdomain name as found in your URL' },
      {name: 'apikey', control_type: :password, label: 'API Key', optional: false}
    ],
    authorization: {
      type: 'basic',

      credentials: ->(connection) {
        params(apiKey: "#{connection['apikey']}")
      }

    },
  },

  object_definitions: {
    project: {
      fields: ->(connection, config) {
        get("https://#{connection['subdomain']}.workfront.com/attask/api/v7.0/proj/metadata")['data']['fields'].
        map do |key, value|
          if value['fieldType'] == 'string' && value['enumType'].blank?
            { name: key, label: "#{value['label']}", type: :string, control_type: :text}
          elsif value['fieldType'] == 'double'
            { name: key, label: "#{value['label']}", type: :ineger, control_type: :number, }
          elsif value['fieldType'] == 'date'
            { name: key, type: :date,  label: "#{value['label']}" }
          elsif value['fieldType'] == 'boolean'
            { name: key, label: "#{value['label']}", type: :boolean}
          elsif value['fieldType'] == 'string' && !value['enumType'].blank?
            string_list = value['possibleValues'].map do |item|
              [ item['label'], item['value']]
            end
            {name: key, label: "#{value['label']}", type: :string, control_type: :select,
             pick_list: string_list,
             toggle_hint: "Select from list",
             toggle_field: {
               name: key,
               label: "#{value['label']}",
               type: :string,
               control_type: "text",
               optional: false,
               toggle_hint: "Use custom value",
               hint: ""
            }  }
          elsif value['fieldType'] == 'string[]' && !value['enumType'].blank?
            select_list = value['possibleValues'].map do |item|
              [ item['label'], item['value']]
            end
            {name: key, label: "#{value['label']}", type: :string, control_type: :select,
             pick_list: select_list,
             toggle_hint: "Select from list",
             toggle_field: {
               name: key,
               label: "#{value['label']}",
               type: :string,
               control_type: "text",
               optional: false,
               toggle_hint: "Use custom value",
               hint: ""
            } }
          elsif value['fieldType'] == 'string[]' && value['enumType'].blank?
            { name: key, label: "#{value['label']}", type: :string, control_type: :text}
          elsif value['fieldType'] == 'dateTime'
            { name: key, type: :date_time, label: "#{value['label']}" }
          elsif value['fieldType'] == 'int'
            { name: key, label: "#{value['label']}", type: :integer, control_type: :number}
          elsif value['fieldType'] == 'map'
            { name: key, label: "#{value['label']}"}
          else
            { name: key, label: "#{value['label']}", type: :string, control_type: :text}
          end
        end
      }

    },
    project_output: {
      fields: ->(connection, config) {
        get("https://#{connection['subdomain']}.workfront.com/attask/api/v7.0/proj/metadata")['data']['fields'].
        map do |key, value|
          if value['fieldType'] == 'string'
            { name: key, label: "#{value['label']}", type: :string, control_type: :text}
          elsif value['fieldType'] == 'double'
            { name: key, label: "#{value['label']}", type: :ineger, control_type: :number, }
          elsif value['fieldType'] == 'date'
            { name: key, label: "#{value['label']}", type: :datetime, control_type: :timestamp, }
          elsif value['fieldType'] == 'boolean'
            { name: key, label: "#{value['label']}", type: :boolean}
          elsif value['fieldType'] == 'string[]' && !value['enumType'].blank?
            {name: key, label: "#{value['label']}", type: :string }
          elsif value['fieldType'] == 'string[]' && value['enumType'].blank?
            { name: key, label: "#{value['label']}", type: :string, control_type: :text}
          elsif value['fieldType'] == 'dateTime'
            { name: key, label: "#{value['label']}", type: :datetime, control_type: :timestamp }
          elsif value['fieldType'] == 'int'
            { name: key, label: "#{value['label']}", type: :integer, control_type: :number}
          elsif value['fieldType'] == 'map'
            { name: key, label: "#{value['label']}"}
          else
            { name: key, label: "#{value['label']}", type: :string, control_type: :text}
          end
        end
      }

    }
  },
  test: ->(connection) {
    (get("https://#{connection['subdomain']}.workfront.com/attask/api/v7.0/project/search")['data'].first || {} )
  },
  actions: {
    get_project_details_by_id: {
      description: 'Get <span class="provider">Project</span> details by Project ID in <span class="provider">WorkFront</span>',
      subtitle: 'Get Project details in WorkFront',
      help: 'Fetches the project details for the given Project ID',
      input_fields: ->(object_definitions){
        [
          {name: 'ID', type: :string, optional: false, label: 'Project ID'}
        ]

      },
      execute: ->(connection, input){

        project = get("https://#{connection['subdomain']}.workfront.com/attask/api/project/"+input['ID']).
        params(fields: "*")['data']
        {
          project: project
        }
      },
      output_fields: ->(object_definitions){
        [
          {
            name: 'project', type: :object, label: 'Project', properties: object_definitions['project']
          }
        ]
      },
      sample_output: ->(connection, object_definitions){
        get("https://#{connection['subdomain']}.workfront.com/attask/api/project/search").
        params(
          fields: '*', # get all fields
          #fields: 'parameterValues', # get all custom fields
        )['data']&.first || {}
      }

    },
    search_projects: {
      description: 'Search <span class="provider">Projects</span> in <span class="provider">WorkFront</span>',
      subtitle: 'Search Projects with details in WorkFront',
      help: 'Search Projects which matches the criteria from WorkFront',
      input_fields: ->(object_definitions){
        [
          # added for enhancement if customer want to support multiple criteria
          #{name: 'ID', type: :string, label: 'Project ID', hint: 'Fetch projects with Project IDs, IDs should be separated by comma'},
          {name: 'name', type: :string, sticky: :true, label: 'Project Name', hint: 'Fetch projects that contains this keyword'},
          #           {name: 'companyID', type: :string, label: 'Company ID', hint: 'Fetch projects that belong to this company'},
          #           {name: 'categoryID', type: :string, label: 'Category ID', hint: 'Fetch projects of this Category'},
          #           {name: 'customerID', type: :string, label: 'Customer ID', hint: 'Fetch projects which belong to the Customer'},
          #           {name: 'ownerID', type: :string, label: 'Owner ID', hint: 'Fetch projects belong to this owner'},
          #           {name: 'status', type: :string, control_type: :select, pick_list: [
          #             ['Current', 'CUR'],
          #             ['On Hold', 'ONH'],
          #             ['Planning', 'PLN'],
          #             ['Complete', 'CPL'],
          #             ['Dead', 'DED'],
          #             ['Requested', 'REQ'],
          #             ['Approved', 'APR'],
          #             ['Rejected','REJ'],
          #             ['Idea','IDA']
          #             ]}
        ]

      },
      execute: ->(connection, input){

        projects = get("https://#{connection['subdomain']}.workfront.com/attask/api/project/search").
        params(
          #ID: input['ID'],
          name: input['name'],
          name_Mod: 'contains',
        fields: "*")['data']
        {
          projects: projects
        }
      },
      output_fields: ->(object_definitions){
        [
          { name: 'projects', type: :array, of: :object, label: 'Projects', properties: object_definitions['project'] }

        ]

      },
      sample_output: ->(connection, object_definitions){
        projects = get("https://#{connection['subdomain']}.workfront.com/attask/api/project/search").
        params(
          fields: '*', # get all fields
          #fields: 'parameterValues', # get all custom fields
        )['data']&.first || {}

        {
          projects: projects
        }
        #{ name: 'projects', type: :array, of: :object, label: 'Projects', properties: object_definitions['project'] }
      }

    },
    create_project: {
      description: 'Create <span class="provider">Project</span> in <span class="provider">WorkFront</span>',
      subtitle: 'Create Project with details in WorkFront',
      help: 'Create Project with details in WorkFront, Select the feilds which are candidate for Project create action',
      input_fields: -> (object_definitions){
        object_definitions['project'].ignored('ID','lastUpdateDate','lastUpdatedByID', 'entryDate', 'enteredByID').required('name')
      },
      execute: ->(connection, input){

        params = input.map do |key, value|
          if key.downcase.include?("date")
            "#{key}=" + value.to_time.in_time_zone("US/Eastern").iso8601
          else
            "#{key}=#{value}"
          end
        end.join('&')

        project = post("https://#{connection['subdomain']}.workfront.com/attask/api/project?"+ params).params(fields: '*') ['data']
        {
          project: project
        }
      },
      output_fields: ->(object_definitions){
        [
          {name: 'project', type: :object, label: 'Project', properties: object_definitions['project']}
        ]
      },
      sample_output: ->(connection, object_definitions){
        get("https://#{connection['subdomain']}.workfront.com/attask/api/project/search").
        params(
          fields: '*', # get all fields
          #fields: 'parameterValues', # get all custom fields
        )['data']&.first || {}
      }
    }

  },

  triggers: {
    new_updated_project: {
      description: 'New or Updated <span class="provider">Project</span> in <span class="provider">WorkFront</span>',
      subtitle: 'New or Updated Project in WorkFront',
      help: 'Trigger will poll based on the User plan',
      input_fields: ->(object_definitions) {
        [
          name: 'since', type: :date_time, sticky: :true, label: 'From', hint: "Fetch Projects from specified Date"
        ]
      },
      poll: ->(connection, input, last_updated_time) {
        last_updated_time = last_updated_time || input['since'] ||  Time.now.to_time #- 10.days
        projects = get("https://#{connection['subdomain']}.workfront.com/attask/api/project/search").
        params(
          fields: '*', # get all fields
          fields: 'parameterValues', # get all custom fields values
          lastUpdateDate: last_updated_time.to_time.in_time_zone("US/Eastern").iso8601,
          lastUpdateDate_Mod: 'gt'
        )['data']
        projects.sort_by {|obj| obj['lastUpdateDate']} unless projects.blank?
        last_modfied_time = projects.last['lastUpdateDate'] unless projects.blank?
        puts projects.size


        {
          events: projects,
          next_poll: last_modfied_time,
          can_poll_more: projects.size > 0
        }
      },
      dedup: ->(project){
        project['ID'] + '@' + project['lastUpdateDate']
      },
      output_fields: ->(object_definitions) {
        object_definitions['project_output']
      },
      sample_output: ->(connection, object_definitions){
        get("https://#{connection['subdomain']}.workfront.com/attask/api/project/search").
        params(
          fields: '*', # get all fields
          #fields: 'parameterValues', # get all custom fields
        )['data']&.first || {}
      }

    }
  }
}
