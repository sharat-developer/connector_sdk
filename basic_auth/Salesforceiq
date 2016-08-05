{
  title: 'SalesforceIQ',

  connection: {
    fields: [
      { name: 'api_key', label: 'API Key', optional: false },
      { name: 'api_secret', label: 'API Secret', optional: false, control_type: 'password' },
      { name: 'list', label: 'List', optional: false, control_type: 'text' }
    ],

    authorization: {
      type: 'basic_auth',

      credentials: ->(connection) {
        user(connection['api_key'])
        password(connection['api_secret'])
      }
    }
  },
  
  test: ->(connection) {
    get("https://api.salesforceiq.com/v2/accounts?_limit=1")
  },

  object_definitions: {
    
		account: {
      fields: ->(connection) {
        [
        	{ name: 'id' },
          { name: 'name' },
          { name: 'modifiedDate', type: :integer }, # milliseconds since epoch
        ].concat(
          get("https://api.salesforceiq.com/v2/accounts/fields")['fields'].
            map do |field|
              pick_list = field['listOptions'].map { |o| [o['display'], o['id']] } if field['dataType'] == 'List'
              { 
                name:  "iq_" + field['id'],
                label: field['name'],
                control_type: field['dataType'] == 'List' ? 'select' : 'text',
                pick_list: pick_list
              }
          	end
        )
      }
    },
    
    list: {
      fields: ->(connection) {
           [
             { name: 'id'},
             { name: 'modifiedDate'},
             { name: 'title'},
             { name: 'listType'},
           ].concat(
             get("https://api.salesforceiq.com/v2/lists")['fields'].
               map do |field|
                 pick_list = field['listOptions'].map { |o| [o['display'], o['id']] } if field['listType'] == 'List'
                 {
                   name: "iq_" + field['id'],
                   label: field['name'],
                   control_type: field['listType'] == 'List' ? 'select' : 'text',
                   
                   pick_list: pick_list
                   }
               end
             )
        }
    },
    
    list_item_with_fieldvalues: {
      fields: ->(connection){
         [
              { name: 'id'},
              { name: 'listId'},
              { name: 'version'},
              { name: 'createdDate'},
              { name: 'modifiedDate'},
              { name: 'name'},
              { name: 'accountId'},
              { name: 'contactIds', type: :object, properties: [
                { name: 'id'},
                { name: 'name'},
                { name: 'email'},
                { name: 'phone'},
                { name: 'address'}
               ]
              },
              { name: 'fieldValues', type: :object, properties: ( 
                	get("https://api.salesforceiq.com/v2/lists/#{connection['list']}")['fields'].
                    map do |field|
                      pick_list = field['listOptions'].map { |o| [o['display'], o['id']] } if field['dataType'] == 'List'
                      { 
                        name:  "iq_" + field['id'],
                        label: field['name'],
                        control_type: field['dataType'] == 'List' ? 'select' : 'text',
                        pick_list: pick_list
                      }
                    end
                )
              },
              { name: 'linkedItemIds'}
          ]
      }
    },

    list_item1: {
      test:->(connection){
        get("https://api.salesforceiq.com/v2/lists/#{connection['list']}")
      },
      fields: ->(connection){
         [
              { name: 'Id'},
              { name: 'modifiedDate', type: :datetime },
              { name: 'createdDate', type: :datetime },
              { name: 'listId'}, 
              { name: 'accountId'},
              { name: 'contactIds', hint: "takes in only one contactID"},
              { name: 'name'}].concat(
                	get("https://api.salesforceiq.com/v2/lists/#{connection['list']}")['fields'].
                    map do |field|
                      pick_list = field['listOptions'].map { |o| [o['display'], o['id']] } if field['dataType'] == 'List'
                      { 
                        name:  "iq_" + field['id'],
                        label: field['name'],
                        control_type: field['dataType'] == 'List' ? 'select' : 'text',
                        pick_list: pick_list
                      }
                    end
                )
      }
    },
    
    contact: {
      fields: ->(connection) {
        [
        	{ name: 'id' },
          { name: 'name' },
          { name: 'email'},
          { name: 'phone'},
          { name: 'address'},
          { name: 'liurl'},
          { name: 'twhan'},
          { name: 'company'},
          { name: 'title'}
        ]
    },
  },
 },

  actions: {
    
    create_account: {
			input_fields: ->(object_definitions) {
        obj = object_definitions['account'].reject { |field| field['id'] }
      },
      
      execute: ->(connection,input) {
        fields = {}
        input.each do |k, v|
          if k != "name"
          	k = k.gsub(/\Aiq_/, '')
          	fields[k] = [ { raw: v } ] 
          end
        end
        post("https://api.salesforceiq.com/v2/accounts", { name: input[:name], fieldValues: fields})
      },
      
      output_fields: ->(object_definitions) {
      	object_definitions['account']
      }
    },
    
    create_list_item: {
			input_fields: ->(object_definitions) {

        (object_definitions['list_item1'].reject { |field| field['Id']})
      },
      
      execute: ->(connection, input) {

        fields ={}
        input.each do |k, v|
          if k != "name"
            k = k.gsub(/\Aiq_/, '')
            fields[k] = [{ raw: v}]
          end
        end
        
        result = post("https://api.salesforceiq.com/v2/lists/#{connection['list']}/listitems").
          #payload({name: input[:name], fieldValues: fields})
           payload({name: input[:name], fieldValues: fields, listId: input[:listId], accountId: input[:accountId], contactIds: (input['contactIds'] or "").split(",")})
        
      },
      
      output_fields: ->(object_definitions) {
      	object_definitions['list_item1']
      }
    },
    
    get_list_items: {
       input_fields: ->(){
       },
      
       execute: ->(connection, input){
           listitems = get("https://api.salesforceiq.com/v2/lists/#{connection['list']}/listitems")['objects']#result returns in ascending order/latest record at the bottom

           listitems.each do |listitem|
              if (listitem['contactIds'].present?)
                contact = get("https://api.salesforceiq.com/v2/contacts/#{listitem['contactIds'].first}")
                new_contactIds = {}
                new_contactIds['id'] = listitem['contactIds'].first
                contact['properties'].each { |name, data| new_contactIds[name] = data.first['value']}
                listitem['contactIds'] = new_contactIds

              end
              field_values_hash = {}
              listitem['fieldValues'].each { |id, raw_container| field_values_hash["iq_#{id}"] = raw_container.first['raw'] }
              listitem['fieldValues'] = field_values_hash
           end 
         
         { listitems: listitems }
         
       },

       output_fields: ->(object_definitions){
         { name: 'listitems', type: :array, of: :object, properties: [object_definitions['list_item_with_fieldvalues']]}
       }
    },
    
    get_list_items_by_ID: {
       input_fields: ->(){
         [
         		{ name: 'list_item_id', optional: false }
         ]
       },
      
       execute: ->(connection, input){
           listitems = get("https://api.salesforceiq.com/v2/lists/#{connection['list']}/listitems/#{input['list_item_id']}")#result returns in ascending order/latest record at the bottom

           if (listitems['contactIds'].present?)
             contact = get("https://api.salesforceiq.com/v2/contacts/#{listitems['contactIds'].first}")
             new_contactIds = {}
             new_contactIds['id'] = listitems['contactIds'].first
              contact['properties'].each { |name, data| new_contactIds[name] = data.first['value']}
              listitems['contactIds'] = new_contactIds
           end
              field_values_hash = {}
              listitems['fieldValues'].each { |id, raw_container| field_values_hash["iq_#{id}"] = raw_container.first['raw'] }
         			listitems['fieldValues'] = field_values_hash
           listitems
       },
      
       output_fields: ->(object_definitions){
         object_definitions['list_item_with_fieldvalues']
       }
    },
    
    update_list_item: {
			input_fields: ->(object_definitions) {
        [{ name: 'List_item', hint: 'please select your listItem from the list in your connection to update', 
            control_type: 'select', pick_list: 'list_items', optional: false}]
            .concat(
              object_definitions['list_item1'].reject { |field| field['id'] or field['modifiedDate'] or field['createdDate']}
            )
      },
      
      execute: ->(connection, input) {
        
        puts input.to_s
        fields ={}
        input.each do |k, v|
          if k != "name"
            k = k.gsub(/\Aiq_/, '')
            fields[k] = [{ raw: v}]
          end
        end
        
        result = put("https://api.salesforceiq.com/v2/lists/#{connection['list']}/listitems/#{input['List_item']}").
          #payload({name: input[:name], fieldValues: fields})
           payload({name: input[:name], fieldValues: fields, listId: input[:listId], accountId: input[:accountId], contactIds: (input['contactIds'] or "").split(",")})
        
      },
      
      output_fields: ->(object_definitions) {
      	object_definitions['list_item1']
      }
    },
    
     create_contact: {
			input_fields: ->(object_definitions) {
         [  { name: 'name' },
          	{ name: 'email'},
            { name: 'phone'},
            { name: 'address'},
            { name: 'liurl'},
            { name: 'twhan'},
            { name: 'company'},
            { name: 'title'}
         ]
      },
      
      execute: ->(connection,input) {
        properties = {}
        properties = input.map { |k,v| { k => [ {"value" => v } ] }}.inject(:merge)
        
        response = post("https://api.salesforceiq.com/v2/contacts").payload(properties: properties)
        
        response['properties'] = response['properties'].map do |k,v|
          { k => v.first['value'] }
        end.inject(:merge)
        
        {"id": response['id']}.merge(response['properties'])
      },
      
      output_fields: ->(object_definitions) {
      	object_definitions['contact']
      }
    }
  },

  triggers: {
		new_accounts: {
      
      input_fields: -> (object_definitions) {
        [{ name: 'since', type: :timestamp }]
      },
      
      poll: -> (connection, input, modified_date_since) {
        modified_date = modified_date_since || (input['since'].to_time.to_f * 1000).to_i

        accounts = get("https://api.salesforceiq.com/v2/accounts").
                     params(
                       _limit: 50,
                       _start: 0,
                       modifiedDate: modified_date
                     )['objects']#result returns in ascending order

        # TODO Handle the mass update case by storing the page number
        if accounts.size == 0
					modified_date_since = (Time.now.to_f * 1000).to_i
        else
          modified_date_since = accounts.last['modifiedDate']
        end
        {
          events: accounts,
          next_poll: modified_date_since,
          can_poll_more: accounts.size == 50
        }
      },
      
      sort_by: ->(account) {
        account['modifiedDate']
      },

      dedup: ->(account) {
        [account['id'], account['modifiedDate']].join("_")
      },
      
      output_fields: ->(object_definitions) {
        object_definitions['account']
      }
    },
    

    
    new_updated_list_items: {
      
      input_fields: -> (object_definitions) {
        [{ name: 'since', type: :timestamp }]
      },
      
     poll: -> (connection, input, modified_date_since) {
        modified_date = modified_date_since || (input['since'].to_time.to_f * 1000).to_i
        

        listitems = get("https://api.salesforceiq.com/v2/lists/#{connection['list']}/listitems").
                     params(
                       _limit: 50,
                       _start: 0,
                       modifiedDate: modified_date
                     )['objects']#result returns in ascending order/latest record at the bottom
       
       listitems.each do |listitem|
          if (listitem['contactIds'].present?)
            contact = get("https://api.salesforceiq.com/v2/contacts/#{listitem['contactIds'].first}")
          	new_contactIds = {}
          	new_contactIds['id'] = listitem['contactIds'].first
          	contact['properties'].each { |name, data| new_contactIds[name] = data.first['value']}
          	listitem['contactIds'] = new_contactIds

          end
          field_values_hash = {}
          listitem['fieldValues'].each { |id, raw_container| field_values_hash["iq_#{id}"] = raw_container.first['raw'] }
          listitem['fieldValues'] = field_values_hash
       end 


        # TODO Handle the mass update case by storing the page number
        if listitems.size == 0
					modified_date_since = (Time.now.to_f * 1000).to_i
        else

          modified_date_since = listitems.last['modifiedDate']
        end
        {
          events: listitems,
          next_poll: modified_date_since,
          can_poll_more: listitems.size == 50
        }
      },
      
      dedup: ->(listitem) {
        [listitem['id'], listitem['modifiedDate']].join("_")      
      },
      
      output_fields: ->(object_definitions) {
        object_definitions['list_item_with_fieldvalues']
      }
    }
  },

  pick_lists: {
    lists: ->(connection){
      get("https://api.salesforceiq.com/v2/lists")['objects'].map {
        |fields| [ fields['title'], fields['id']]}
      },
    
    list_items: ->(connection){
      listitems = get("https://api.salesforceiq.com/v2/lists/#{connection['list']}/listitems")['objects'].map {
         | fields| [fields['name'], fields['id']]}
      }
  }
}
