{
  title: 'PipelinerCRM',
    connection: {
      fields: [
        {
          name: 'deployment',
          control_type: 'subdomain',
          url:'.pipelinersales.com',
          optional:false,
          hint: 'Enter your Service URL Eg. eu-central-1'
        },
        {
          name: 'spaceId',
          optional:false,
          hint: 'Enter your Team Space ID'
        },
        {
         name: 'username',
         optional: true,   
         hint: 'Enter your API token'
        },
        {
         name: 'password',
         control_type: 'password',
         label: 'Password',
         hint: 'Enter your API password'
        },     
     ],
    
    authorization: {
      type: 'basic_auth',
      credentials: ->(connection) {    
        user(connection['username'])
        password(connection['password'])
      }
    }
  },
  
  object_definitions: {
    lead: {
      fields: ->() {
        [ 
          {name: 'SALES_UNIT_ID',label: 'Sales unit ID',hint: 'ID of the related Sales Unit'},     
          {name: 'CREATED', type: :datetime,label: 'Created'},
          {name: 'MODIFIED', type: :datetime,label: 'Modified'},
          {name: 'ID'},
          {name: 'OPPORTUNITY_NAME',label: 'Opportunity name',hint: 'Name of the Lead'},
          {name: 'OPPORTUNITY_DESCRIPTION',label: 'Opportunity description',hint: 'Description of the Lead'},
          {name: 'OWNER_ID', type: :integer,label: 'Owner ID',hint: 'It is the ID of the Client owns the Lead'},
          {name: 'ACCESS_LEVEL', type: :integer,label: 'Access level'},
          {name: 'ACCOUNT_RELATIONS', type: :list,label: 'Account relations'},
          {name: 'CONTACT_RELATIONS', type: :list,label: 'contact relations'},
          {name: 'IS_ARCHIVE', type: :integer,label: 'Is archive'},
          {name: 'LAST_MOVE_DATE', type: :integer,label: 'Last move date'},
          {name: 'IS_DELETED', type: :integer,label: 'Is deleted'},
          {name: 'PUBLISH_STATE', type: :integer,label: 'Publish state'},
          {name: 'QUICK_ACCOUNT_EMAIL',label: 'Quick account email',hint:'Email of the account'},
          {name: 'QUICK_ACCOUNT_NAME',label: 'Quick account name',hint: 'Name of the account'},
          {name: 'QUICK_ACCOUNT_PHONE',label: 'Quick account phone',hint: 'Phone of the account'},
          {name: 'QUICK_CONTACT_NAME',label: 'Quick contact name',hint: 'Name of the contact'},
          {name: 'QUICK_EMAIL',label: 'Quick email',hint: 'Email of the contact'},
          {name: 'QUICK_PHONE',label: 'Quick phone',hint: 'Phone of the contact'},
          {name: 'RANKING', type: :integer,label: 'Ranking',hint: 'Rank of the Lead. Between 1 to 100'},
          {name: 'SALES_TEAM', type: :list,label: 'Sales team',hint: 'Client Id who can edit the Lead'},
          {name: 'WATCHERS', type: :list,label: 'Watchers',hint: 'Client Id who has read access to the Lead'},
         ]
       }
    },
    
    product: {
      fields: ->() {
        [
          {name: 'ID'},
          {name: 'PRODUCT_CATEGORY_ID',label: 'Product category ID',hint: 'Reference to the parent category'},
          {name: 'NAME',label: 'Name'},
          {name: 'DESCRIPTION',label: 'Description',hint: 'Description of the product'},
          {name: 'CREATED', type: :datetime,label: 'Created'},
          {name: 'MODIFIED', type: :datetime,label: 'Modified'},
          {name: 'IS_DELETED', type: :integer,label: 'Is deletd',hint: '0 - entity is active, 1 - entity is deleted'},
          {name: 'SKU',label: 'SKU',hint: 'Unique product SKU number'},
          {name: 'UNIT_SYMBOL',label: 'Unit symbol',hint: 'Symbol of product unit (e.g. kg, pc, m2)'},
         ]
       }
    },
    
    accounts: {
      fields: ->() {
        [
          {name: 'ACCESS_LEVEL', type: :integer,label: 'Access level'},
          {name: 'ACCOUNT_CLASS', type: :integer,label: 'Account class'},
          {name: 'ACCOUNT_TYPE_ID',label: 'Account type ID'},
          {name: 'ADDRESS',label: 'Address'},
          {name: 'CITY',label: 'City'},
          {name: 'COMMENTS',label: 'Comments'},
          {name: 'EMAIL1',label: 'Email1',hint: 'Primary Email'},
          {name: 'EMAIL2',label: 'Email2'},
          {name: 'EMAIL3',label: 'Email3'},
          {name: 'EMAIL4',label: 'Email4'},
          {name: 'EMAIL5',label: 'Email5'},
          {name: 'ID'},
          {name: 'INDUSTRIES_ID',label: 'Industries ID',hint: 'ID of related Industry'},
          {name: 'ORGANIZATION',label: 'Organization',hint: 'Name of the Account'},
          {name: 'OWNER_ID', type: :integer,label: 'Owner ID',hint: 'ID of the client who owns the Account'},
          {name: 'PARENT_ACCOUNT_ID',label: 'Parent account Id'},
          {name: 'PARENT_ACCOUNT_RELATION_TYPE_ID',label: 'Parent account relation type ID'},
          {name: 'PHONE1',label: 'Phone1',hint: 'Primary Phone'},
          {name: 'PHONE2',label: 'Phone2'},
          {name: 'PHONE3',label: 'Phone3'},
          {name: 'PHONE4',label: 'Phone4'},
          {name: 'PHONE5',label: 'Phone5'},
          {name: 'PICTURE', type: :blob,label: 'Picture',hint: 'Profile picture'},
          {name: 'PUBLISH_STATE', type: :integer,label: 'Publish state'},
          {name: 'SALES_UNIT_ID',label: 'Sales unit ID',hint: 'ID of related Sales Unit'},     
          {name: 'STATE_PROVINCE',label: 'State province'},
          {name: 'PARENT_ID',label: 'Parent ID'},
          {name: 'CREATED', type: :datetime,label: 'Created'},
          {name: 'MODIFIED', type: :datetime,label: 'Modified'},
          {name: 'IS_DELETED', type: :integer,label: 'Is deleted'},
          {name: 'ZIP_CODE',label: 'Zip code'},
         ]
       }
    },
    
    contact: {
      fields: ->() {
        [
          {name:'FIRST_NAME',label:'First name'},
          {name:'SURNAME',hint:"last name",label:'Surname'},
          {name:'OWNER_ID',type: :integer,hint:"It is ID of client who owns this contact",label:'Owner ID'},
          {name:'SALES_UNIT_ID',type: :integer,hint:"ID of relatedSalesUnit",label:'Sales unit ID'},
          {name:'ACCESS_LEVEL',type: :integer,label:'Access level'},
          { name: 'ACCOUNT_RELATIONS', type: :array, of: :object,label:"Account relations", properties: [
          { name: 'ACCOUNT_ID',label:'Account ID' },
          { name: 'IS_PRIMARY', type: :integer, hint: "use 1 for true and 0 for false",label:'Is primary'}
          ]},
          {name:'ADDRESS',label:'Address'},
          {name:'CITY',label:'City'},
          {name:'COMMENTS',label:'Comments'},
          {name:'COUNTRY',label:'Country'},
          {name:'CREATED',type: :datetime,label:'Created'},
          {name:'EMAIL1',label:'Email1'},
          {name:'EMAIL2',label:'Email2'},
          {name:'EMAIL3',label:'Email3'},
          {name:'EMAIL4',label:'Email4'},
          {name:'EMAIL5',label:'Email5'},
          {name:'GENDER',type: :integer,label:'Gender'},
          {name:'IS_DELETED',type: :integer,label:'Is deleted'},
          {name:'MIDDLE_NAME',label:'Middle name'},
          {name:'MODIFIED',type: :datetime,label:'Modified'},
          {name:'PHONE1',label:'Phone1'},
          {name:'PHONE2',label:'Phone2'},
          {name:'PHONE3',label:'Phone3'},
          {name:'PHONE4',label:'Phone4'},
          {name:'PHONE5',label:'Phone5'},
          {name:'PICTURE',type: :blob,label:'Picture'},
          {name:'POSITION',label:'Position'},
          {name:'PUBLISH_STATE',type: :integer,label:'Publish state'},
          {name:'QUICK_ACCOUNT_NAME',hint:"Name of the account",label:'Quick account name'},
          {name:'SALES_TEAM',type: :integer,hint:"List of Client ids, who can edit the Contact",label:'Sales team'},
          {name:'SALUTATION',label:'Salutation'},
          {name:'STATE_PROVINCE',label:'State province'},
          {name:'TITLE',label:'Tiltle'},
          {name:'WATCHERS',type: :integer,hint:"List of Client ids, who have read access to the Contact",label:'Watchers'},
          {name:'ZIP_CODE',label:'Zip code'},
          {name:'ID',label:'ID'},
        ]
      }
    },
    
    opportunity: {
      fields: ->() {
        [
          {name:'CLOSING_DATE',type: :datetime,hint:"Estimated closing date of opportunity",label:'Closing date'},
          { name:'CONTACT_RELATIONS', type: :array, of: :object,label:"Contact relations", properties: [
          { name:'CONTACT_ID',label:'Contact ID' },
          { name:'IS_PRIMARY', type: :integer, hint: "use 1 for true and 0 for false",label:'Is primary' }
          ]},
          {name:'OWNER_ID',type: :integer,hint:"It is ID of client who owns this contact",label:'Owner ID'},
          {name:'SALES_UNIT_ID',type: :integer,hint:"ID of relatedSalesUnit",label:'Sales unit ID'},
          {name:'ACCESS_LEVEL',type: :integer,label:'Access level'},
          {name:'ACCOUNT_ID'},
          {name:'IS_PRIMARY'},
          {name:'CURRENCY_EXCHANGE_FIXED',type: :double,label:'Currency exchange fixed'},
          {name:'CURRENCY_ID',label:'Currency ID'},
          {name:'IS_ARCHIVE',type: :integer,label:'Is archive'},
          {name:'LAST_MOVE_DATE',type: :datetime,label:'Last month'},
          {name:'LAST_FINISHE_DATE',type: :datetime,label:'Last finish date'},
          {name:'CREATED',type: :datetime,label:'Created'},
          {name:'OPPORTUNITY_DESCRIPTION',label:'Opportunity description'},
          {name:'OPPORTUNITY_NAME',hint:"Name of the opportunity",label:'Oppportunity name'},
          {name:'OPPORTUNITY_VALUE',type: :double,label:'Opportunity value'},
          {name:'OPPORTUNITY_VALUE_AUTO_CALCULATE',type: :integer,label:'Opportunity value auto calculate'},
          {name:'OPPORTUNITY_VALUE_FOREGIN',type: :double,label:'Opportunity value foregin'},
          {name:'PRODUCT_PRICE_LIST_ID',label:'Product price list ID'},
          {name:'IS_DELETED',type: :integer,label:'Is deleted'},
          {name:'QUICK_ACCOUNT_EMAIL',label:'Quick account email'},
          {name:'MODIFIED',type: :datetime,label:'Modified'},
          {name:'QUICK_ACCOUNT_NAME',label:'Quick account name'},
          {name:'QUICK_ACCOUNT_PHONE',label:'Quick account phone'},
          {name:'QUICK_CONTACT_NAME',label:'Quick contact name'},
          {name:'QUICK_EMAIL',label:'Quick email'},
          {name:'QUICK_PHONE',label:'Quick phone'},
          {name:'RANKING',type: :integer,label:'Ranking'},
          {name:'REASON_OF_CLOSE_DESCRIPTION',label:'Reason of close description'},
          {name:'PUBLISH_STATE',type: :integer,label:'Publish state'},
          {name:'REASON_OF_CLOSE_ID',label:'Reason of close ID'},
          {name:'SALES_TEAM',type: :integer,hint:"List of Client ids, who can edit the Contact",label:'Sales team'},
          {name:'RECCURRENCY_CONDITION',type: :integer,label:'Recurrency condition'},
          {name:'RECURRENCY_DAY',type: :integer,label:'Recurrency day'},
          {name:'RECUURENCY_MONTH',type: :month,label:'Recurrency month'},
          {name:'WATCHERS',type: :integer,hint:"List of Client ids, who have read access to the Contact",label:'Watchers'},
          {name:'RECURRNCY_STAGE_ID',label:'Recurrency stage ID'},
          {name:'RECURRNCY_STARTING_DATE',type: :datetime,label:'Recurrency starting date'},
          {name:'RECURRNCY_TYPE',label:'Recurrency type'},
          {name:'STAGE',hint:"ID of related stage class,where opportunity belongs",label:'Stage'},
          {name:'ID',label:'ID'},
        ]
      }
    }
  },
 
  test: ->(connection) {
    get("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}")
  },

  actions: {
    create_account: {
      description: 'Create <span class="provider">New Account</span> in <span class="provider">Pipeliner CRM</span>',
      input_fields: ->(object_definitions) {
       object_definitions['accounts'].required('SALES_UNIT_ID','OWNER_ID','ORGANIZATION').ignored('ID')
      },
      execute: ->(connection, input) {
        post("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Accounts", input )
       },
      output_fields: ->(object_definitions) {
        object_definitions['accounts']
      }
    },
    
    get_account_by_Id:{
      description: 'Search <span class="provider">Accounts by ID </span> in <span class="provider">Pipeliner CRM</span>',
      input_fields: ->(object_definitions) {
         [
          {
            name: 'ID',
            type: :string,
            optional: false
          }
        ]
      },
      execute: ->(connection, input) {
        get("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Accounts/#{input['ID']}")
      },
      output_fields: ->(object_definitions) {
        object_definitions['accounts']
      }
     },
    
    search_accounts:{
      description: 'Search <span class="provider">Accounts</span> in <span class="provider">Pipeliner CRM</span>',
      input_fields: ->(object_definitions) {
        object_definitions['accounts'].ignored('PICTURE')
      },
      execute: ->(connection, input) {
        fields=input.map do |key,value|
          "#{key}::#{value}"
         end.join('|')
        {
         "account" => [get("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Accounts?filter=#{fields}") ]
         }
       },
      output_fields: ->(object_definitions) {
         [
          { name: 'account', 
            type: :array, of: :object, 
            properties: object_definitions['accounts'] 
           }
         ]
        }
      },
    
    update_account: {
      description: 'Update <span class="provider">Account</span> in <span class="provider">Pipeliner CRM</span>',
      input_fields: ->(object_definitions) {
        object_definitions['accounts'].required('ID')
      },
      execute: ->(connection, input) {
        put("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Accounts/#{input['ID']}",input)
       },
      output_fields: ->(object_definitions) {
        object_definitions['accounts']
      }
    },
    
    delete_account:{
      description: 'Delete <span class="provider">Account</span> in <span class="provider">Pipeliner CRM</span>',
      input_fields: ->(object_definitions) {
         object_definitions['accounts'].only('ID').required('ID')
      },
      execute: ->(connection, input) {
        delete("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Accounts/#{input['ID']}")
      },
      output_fields: ->(object_definitions) {
        object_definitions['accounts']
      }
    }, 
    create_product: {
      description: 'Create <span class="provider">New Product</span> in <span class="provider">Pipeliner CRM</span>',
      input_fields: ->(object_definitions) {
       object_definitions['product'].required('NAME').ignored('ID')
      },
      execute: ->(connection, input) {
        post("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Products", input )
       },
      output_fields: ->(object_definitions) {
        object_definitions['product']
      }
    },
    
    get_product_by_Id:{
      description: 'Get <span class="provider">Product by ID</span> in <span class="provider">Pipeliner CRM</span>',
      input_fields: ->(object_definitions) {
         [
          {
            name: 'ID',
            type: :string,
            optional: false
          }
        ]
      },
      execute: ->(connection, input) {
        get("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Products/#{input['ID']}")
      },
      output_fields: ->(object_definitions) {
        object_definitions['product']
      }
     },
    
    search_products:{
      description: 'Search <span class="provider">Products</span> in <span class="provider">Pipeliner CRM</span>',
      input_fields: ->(object_definitions) {
        object_definitions['product'].ignored('DESCRIPTION')
      },
      execute: ->(connection, input) {
        fields=input.map do |key,value|
          "#{key}::#{value}"
         end.join('|')
        {
         "products" => [get("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Products?filter=#{fields}") ]
         }
       },
      output_fields: ->(object_definitions) {
         [
          { name: 'products', 
            type: :array, of: :object, 
            properties: object_definitions['product'] 
           }
         ]
        }
      },
    
    update_product: {
      description: 'Update <span class="provider">Product</span> in <span class="provider">Pipeliner CRM</span>',
      input_fields: ->(object_definitions) {
        object_definitions['product'].required('ID')
      },
      execute: ->(connection, input) {
        put("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Products/#{input['ID']}",input)
       },
      output_fields: ->(object_definitions) {
        object_definitions['product']
      }
    },
    
    delete_product:{
      description: 'Delete <span class="provider">Product</span> in <span class="provider">Pipeliner CRM</span>',
      input_fields: ->(object_definitions) {
         object_definitions['product'].only('ID').required('ID')
      },
      execute: ->(connection, input) {
        delete("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Products/#{input['ID']}")
      },
      output_fields: ->(object_definitions) {
        object_definitions['product']
      }
    },
    create_lead: {
      description: 'Create <span class="provider">New Lead</span> in <span class="provider">Pipeliner CRM</span>',
      input_fields: ->(object_definitions) {
       object_definitions['lead'].required('OPPORTUNITY_NAME','OWNER_ID','SALES_UNIT_ID').ignored('ID')
      },
      execute: ->(connection, input) {
        post("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Leads", input )
       },
      output_fields: ->(object_definitions) {
        object_definitions['lead']
      }
    },
    
    get_lead_by_Id:{
      description: 'Get <span class="provider">Lead by ID</span> in <span class="provider">Pipeliner CRM</span>',
      input_fields: ->(object_definitions) {
         [
          {
            name: 'ID',
            type: :string,
            optional: false
          }
        ]
      },
      execute: ->(connection, input) {
        get("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Leads/#{input['ID']}")
      },
      output_fields: ->(object_definitions) {
        object_definitions['lead']
      }
     },
    
    search_leads:{
      description: 'Search <span class="provider">Leads</span> in <span class="provider">Pipeliner CRM</span>',
      input_fields: ->(object_definitions) {
        object_definitions['lead'].ignored('DESCRIPTION')
      },
      execute: ->(connection, input) {
        fields=input.map do |key,value|
          "#{key}::#{value}"
         end.join('|')
        {
         "leads" => [get("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Leads?filter=#{fields}") ]
         }
       },
      output_fields: ->(object_definitions) {
         [
          { name: 'leads', 
            type: :array, of: :object, 
            properties: object_definitions['lead'] 
           }
         ]
        }
      },
    
    update_lead: {
      description: 'Update <span class="provider">Lead</span> in <span class="provider">Pipeliner CRM</span>',
      input_fields: ->(object_definitions) {
        object_definitions['lead'].required('ID')
      },
      execute: ->(connection, input) {
        put("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Leads/#{input['ID']}",input)
       },
      output_fields: ->(object_definitions) {
        object_definitions['lead']
      }
    },
    
    delete_lead:{
      description: 'Delete <span class="provider">Lead</span> in <span class="provider">Pipeliner CRM</span>',
      input_fields: ->(object_definitions) {
         object_definitions['lead'].only('ID').required('ID')
      },
      execute: ->(connection, input) {
        delete("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Leads/#{input['ID']}")
      },
      output_fields: ->(object_definitions) {
        object_definitions['lead']
      }
    },
    
    create_contact: {
      description: 'Create <span class="provider">Contact</span> in <span class="provider">PipelinerCRM</span>',
      input_fields: ->(object_definitions) {
        object_definitions['contact'].required('SALES_UNIT_ID','OWNER_ID','SURNAME').ignored('ID')
      },
      execute: ->(connection, input) {
        post("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Contacts", input )
          },
      output_fields: ->(object_definitions) {
        object_definitions['contact']
      }
    },
    
    create_opportunity: {
      description: 'Create <span class="provider">Opportunity</span> in <span class="provider">PipelinerCRM</span>',
      input_fields: ->(object_definitions) {
  object_definitions['opportunity'].required('SALES_UNIT_ID','OWNER_ID','OPPORTUNITY_NAME','STAGE','OPPORTUNITY_VALUE_FOREGIN','CLOSING_DATE','ACCOUNT_ID').ignored('ID')
      },
      execute: ->(connection, input) {
         a=input['ACCOUNT_ID'].split(",")
         b=a.first
         array = a.map do |id|
          {
          "ACCOUNT_ID" => id,
          "IS_PRIMARY" => (1 if b==id)
          }
        end
        input.delete('ACCOUNT_ID')
        post("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Opportunities", input ).payload(ACCOUNT_RELATIONS:array)
       },
      output_fields: ->(object_definitions) {
        object_definitions['opportunity']
      }
    },
    
    get_contact_by_Id:{
      description: 'Get <span class="provider">Contact_by_id</span> in <span class="provider">PipelinerCRM</span>',
      input_fields: ->(object_definitions) {
        object_definitions['contact'].only('ID').required('ID')
      },
      execute: ->(connection, input) {
        get("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Contacts/#{input['ID']}")
      },
      output_fields: ->(object_definitions) {
        object_definitions['contact']
      }
     },
    
    get_opportunity_by_Id:{
      description: 'Get <span class="provider">Opportunity_by_id</span> in <span class="provider">PipelinerCRM</span>',
      input_fields: ->(object_definitions) {
        object_definitions['opportunity'].only('ID').required('ID')
      },
      execute: ->(connection, input) {
        get("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Opportunities/#{input['ID']}")
      },
      output_fields: ->(object_definitions) {
        object_definitions['opportunity']
      }
     },
    
    search_contact:{
      description: 'Search <span class="provider">Contact</span> in <span class="provider">PipelinerCRM</span>',
      input_fields: ->(object_definitions) {
        object_definitions['contact']
        },
      execute: ->(connection, input) {
        c=input.map do |k,v|
          "#{k}::#{v}"
        end.join("|")
          {
       "contacts"=>[get("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Contacts?filter=#{c}")]
            }
      },
      output_fields: ->(object_definitions) {
       [
          {
            name: 'contacts',
            type: :array, of: :object,
            properties: object_definitions['contact']
          }
        ]
       },
      },
    
    search_opportunity:{
      description: 'Search <span class="provider">Opportunity</span> in <span class="provider">PipelinerCRM</span>',
      input_fields: ->(object_definitions) {
        object_definitions['opportunity']
        },
      execute: ->(connection, input) {
        c=input.map do |k,v|
          "#{k}::#{v}"
        end.join("|")
          {
       "opportunities"=>[get("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Opportunities?filter=#{c}")]
            }
      },
     output_fields: ->(object_definitions) {
       [
          {
            name: 'opportunities',
            type: :array, of: :object,
            properties: object_definitions['opportunity']
          }
        ]
       },
      },
    
    update_contact: {
      description: 'Update <span class="provider">Contact</span> in <span class="provider">PipelinerCRM</span>',
      input_fields: ->(object_definitions) {
        object_definitions['contact'].required('ID')
      },
      execute: ->(connection, input) {
          put("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Contacts/#{input['ID']}",input)
       },
      output_fields: ->(object_definitions) {
        object_definitions['contact']
      }
    },
    
    update_opportunity: {
      description: 'Update <span class="provider">Opportunity</span> in <span class="provider">PipelinerCRM</span>',
      input_fields: ->(object_definitions) {
        object_definitions['opportunity'].required('ID')
      },
      execute: ->(connection, input) {
          put("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Opportunities/#{input['ID']}",input)
       },
      output_fields: ->(object_definitions) {
        object_definitions['opportunity']
      }
    },
    delete_contact:{
      description: 'Delete <span class="provider">Contact</span> in <span class="provider">PipelinerCRM</span>',
      input_fields: ->(object_definitions) {
        object_definitions['contact']
      },
      execute: ->(connection, input) {
         delete("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Contacts/#{input['ID']}")
      },
      output_fields: ->(object_definitions) {
        object_definitions['contact']
      }
    },
    
   delete_opportunity:{
      description: 'Delete <span class="provider">Opportunity</span> in <span class="provider">PipelinerCRM</span>',
      input_fields: ->(object_definitions) {
        object_definitions['opportunity']
      },
      execute: ->(connection, input) {
         delete("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Opportunities/#{input['ID']}")
      },
      output_fields: ->(object_definitions) {
        object_definitions['opportunity']
      }
    }
  },
  
  triggers: {
    new_account: {
      description: 'New <span class="provider">Account</span> in <span class="provider">Pipeliner CRM</span>',
      type: :paging_desc,
     	input_fields: ->() {
        [
          {
            name: 'since',
            type: :timestamp,
           }
        ]
       },
      poll: ->(connection, input, last_created_since) {
        since = (last_created_since || input['since']|| Time.now).to_time.utc.iso8601
       	responses = get("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Accounts?limit=100&offset=0&sort=CREATED&filter=CREATED::#{since}::gt")
       	last_created_since = responses.last['CREATED'] unless responses.blank?
       	responses = responses.select do |response|
        	 response['CREATED'] == response['MODIFIED']
       	end
        {
          events: responses.reverse,
          next_page: responses >= 100 ? last_created_since:nil,
        }
      },
      document_id: ->(accounts) {
        accounts['ID']
      },
      output_fields: ->(object_definitions) {
        object_definitions['accounts']
      }  
     },
    
    updated_account: {
      description: 'Update <span class="provider">Account</span> in <span class="provider">Pipeliner CRM</span>',
      type: :paging_desc,
     	input_fields: ->() {
        [
          {
            name: 'since',
            type: :timestamp,
           }
        ]
      },
      poll: ->(connection, input, last_updated_since) {
        since = (last_updated_since || input['since'] || Time.now).to_time.utc.iso8601
       	responses = get("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Accounts?limit=100&offset=0&sort=MODIFIED&filter=MODIFIED::#{since}::gt")
       	last_created_since = responses.last['MODIFIED'] unless responses.blank?
       	responses = responses.select do |response|
        	 response['CREATED'] < response['MODIFIED']
       	end
        {
          events: responses.reverse,
          next_page: responses >= 100 ? last_created_since:nil,
        }
      },
      document_id: ->(accounts) {
        accounts['ID']
        },
      sort_by: ->(accounts) {
        accounts['MODIFIED']
        },
      output_fields: ->(object_definitions) {
        object_definitions['accounts']
      }  
     },
    
    new_product: {
      description: 'New <span class="provider">Product</span> in <span class="provider">Pipeliner CRM</span>',
      type: :paging_desc,
     	input_fields: ->() {
        [
          {
            name: 'since',
            type: :timestamp,
           }
        ]
       },
      poll: ->(connection, input, last_created_since) {
        since = (last_created_since || input['since']|| Time.now).to_time.utc.iso8601
       	responses = get("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Products?limit=100&offset=0&sort=CREATED&filter=CREATED::#{since}::gt")
       	last_created_since = responses.last['CREATED'] unless responses.blank?
       	responses = responses.select do |response|
        	 response['CREATED'] == response['MODIFIED']
       	end
        {
          events: responses.reverse,
          next_page: responses >= 100 ? last_created_since:nil,
        }
      },
      document_id: ->(product) {
        product['ID']
      },
      output_fields: ->(object_definitions) {
        object_definitions['product']
      }  
     },
    
    updated_product: {
      description: 'Update <span class="provider">Product</span> in <span class="provider">Pipeliner CRM</span>',
      type: :paging_desc,
     	input_fields: ->() {
        [
          {
            name: 'since',
            type: :timestamp,
          }
        ]
      },
      poll: ->(connection, input, last_updated_since) {
        since = (last_updated_since || input['since'] || Time.now).to_time.utc.iso8601
       	responses = get("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Products?limit=100&offset=0&sort=MODIFIED&filter=MODIFIED::#{since}::gt")
       	last_created_since = responses.last['MODIFIED'] unless responses.blank?
       	responses = responses.select do |response|
        	 response['CREATED'] < response['MODIFIED']
       	end
        {
          events: responses.reverse,
          next_page: responses >= 100 ? last_created_since:nil,
        }
      },
      document_id: ->(product) {
        product['ID']
        },
      sort_by: ->(product) {
        product['MODIFIED']
        },
      output_fields: ->(object_definitions) {
        object_definitions['product']
      }  
     },
    
    new_lead: {
      description: 'New <span class="provider">Lead</span> in <span class="provider">Pipeliner CRM</span>',
      type: :paging_desc,
     	input_fields: ->() {
        [
          {
            name: 'since',
            type: :timestamp,
          }
        ]
       },
      poll: ->(connection, input, last_created_since) {
        since = (last_created_since || input['since']|| Time.now).to_time.utc.iso8601
       	responses = get("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Leads?limit=100&offset=0&sort=CREATED&filter=CREATED::#{since}::gt")
       	last_created_since = responses.last['CREATED'] unless responses.blank?
       	responses = responses.select do |response|
        	 response['CREATED'] == response['MODIFIED']
       	end
        {
          events: responses.reverse,
          next_page: responses >= 100 ? last_created_since:nil,
        }
      },
      document_id: ->(lead) {
        lead['ID']
      },
      output_fields: ->(object_definitions) {
        object_definitions['lead']
      }  
     },
    
    updated_lead: {
      description: 'Update <span class="provider">Lead</span> in <span class="provider">Pipeliner CRM</span>',
      type: :paging_desc,
     	input_fields: ->() {
        [
          {
            name: 'since',
            type: :timestamp,
          }
        ]
      },
      poll: ->(connection, input, last_updated_since) {
        since = (last_updated_since || input['since'] || Time.now).to_time.utc.iso8601
       	responses = get("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Leads?limit=100&offset=0&sort=MODIFIED&filter=MODIFIED::#{since}::gt")
       	last_created_since = responses.last['MODIFIED'] unless responses.blank?
       	responses = responses.select do |response|
        	 response['CREATED'] < response['MODIFIED']
       	end
        {
          events: responses.reverse,
          next_page: responses >= 100 ? last_created_since:nil,
        }
      },
      document_id: ->(lead) {
        lead['ID']
        },
      sort_by: ->(lead) {
        lead['MODIFIED']
        },
      output_fields: ->(object_definitions) {
        object_definitions['lead']
      }  
     },
    
    new_contact: {
      description: 'New <span class="provider">Contact</span> in <span class="provider">PipelinerCRM</span>',
      type: :paging_desc,
      input_fields: ->() {
        [
          {
            name: 'since',
            type: :timestamp,
          }
        ]
      },
      poll: ->(connection, input, last_created_since) {
        since = (last_created_since || input['since'].to_time.utc.iso8601||Time.now)
           responses = get("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Contacts?limit=100&offset=0&sort=-CREATED&filter=CREATED::#{since}::gt")
           last_created_since = responses.last['CREATED'].to_time.utc.iso8601 unless responses.blank?
        responses = responses.select do |response|
             response['CREATED'] == response['MODIFIED']
           end
       {
          events: responses,
          next_page: responses.length >= 100 ? last_created_since : nil ,
        }
      },
     document_id: ->(contact) {
        contact['ID']
      },
     output_fields: ->(object_definitions) {
        object_definitions['contact']
      }  
     },
    
   new_opportunity: {
     description: 'New <span class="provider">Opportunity</span> in <span class="provider">PipelinerCRM</span>',
     type: :paging_desc,
     input_fields: ->() {
        [
          {
            name: 'since',
            type: :timestamp,
          }
        ]
      },

      poll: ->(connection, input, last_created_since) {
        since = (last_created_since || input['since'].to_time.utc.iso8601|| Time.now)
           responses = get("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Opportunities?limit=100&offset=0&sort=-CREATED&filter=CREATED::#{since}::gt")
           last_created_since = responses.last['CREATED'].to_time.utc.iso8601 unless responses.blank?
        responses = responses.select do |response|
            response['CREATED'] == response['MODIFIED']
           end
       {
          events: responses,
          next_page: responses.length >= 100 ? last_created_since : nil ,
       }
      },
     document_id: ->(opportunity) {
        opportunity['ID']
      },
     output_fields: ->(object_definitions) {
        object_definitions['opportunity']
      }  
     },
    
  updated_contact: {
    description: 'Update <span class="provider">Contact</span> in <span class="provider">PipelinerCRM</span>',
    type: :paging_desc,
    input_fields: ->() {
        [
          {
            name: 'since',
            type: :timestamp,
          }
        ]
      },
    poll: ->(connection, input, last_modified_since) {
        since = (last_modified_since || input['since'].to_time.utc.iso8601 || Time.now)
           responses = get("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Contacts?limit=100&offset=0&sort=-MODIFIED&filter=MODIFIED::#{since}::gt")
        last_modified_since = responses.last['MODIFIED'].to_time.utc.iso8601 unless responses.blank?
           responses = responses.select do |response|
             response['CREATED'] < response['MODIFIED']
           end
        {
          events: responses,
          next_page: responses.length >= 100 ? last_modified_since : nil ,
        }
      },
      document_id: ->(contact) {
        contact['ID']
      },
      sort_by: ->(contact) {
        contact['MODIFIED']
      },
      output_fields: ->(object_definitions) {
        object_definitions['contact']
      }  
     },
    
   updated_opportunity: {
     description: 'Update <span class="provider">Opportunity</span> in <span class="provider">PipelinerCRM</span>',
     type: :paging_desc,
     input_fields: ->() {
        [
          {
            name: 'since',
            type: :timestamp,
          }
        ]
      },
     poll: ->(connection, input, last_modified_since) {
        since = (last_modified_since || input['since'].to_time.utc.iso8601|| Time.now)
           responses = get("https://#{connection['deployment']}.pipelinersales.com/rest_services/v1/#{connection['spaceId']}/Opportunities?limit=100&offset=0&sort=-MODIFIED&filter=MODIFIED::#{since}::gt")
        last_modified_since = responses.last['MODIFIED'].to_time.utc.iso8601 unless responses.blank?
           responses = responses.select do |response|
             response['CREATED'] < response['MODIFIED']
           end
        {
          events: responses,
          next_page: responses.length >= 100 ? last_modified_since : nil ,
        }
      },
      document_id: ->(opportunity) {
        opportunity['ID']
      },
      sort_by: ->(opportunity) {
        opportunity['MODIFIED']
      },
      output_fields: ->(object_definitions) {
        object_definitions['opportunity']
      }  
     },
    }
  }
