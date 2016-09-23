{
  title: 'Magento',

  connection: {

    fields: [
      {
        name: 'server',
        label: 'Server domain',
        optional: false,
        hint: 'What is your server domain?'
      },
      {
        name: 'token',
        control_type: 'password',
        optional: false,
        hint: 'Find out how to generate a token <a target="_blank" href="http://devdocs.magento.com/guides/v2.1//get-started/authentication/gs-authentication-token.html">here</a>'
      }
    ],
    
    authorization: {
      type: 'custom',

      credentials: lambda do |connection|
        headers("Authorization": "Bearer #{connection['token']}")
      end
    }
  },
  
  test: lambda do |connection|
    get("#{connection['server']}rest/default/V1/attributeMetadata/customer")
  end,

  object_definitions: {
    customer: {
      fields: lambda do
        [
          { name: 'id', type: :integer },
          { name: 'name' },
          { name: 'email' },
          { name: 'created_at', type: :timestamp }
          # additional fields here
        ]
      end
    },
    
    order: {
      fields: lambda do
        [
          { name: 'customer_id', type: :integer },
          { name: 'subtotal', type: :decimal },
          { name: 'entity_id' },
          { name: 'created_at', type: :timestamp },
          { name: 'updated_at', type: :timestamp }
          # additional fields here
        ]
      end 
    }
  },

  triggers: {
    new_customer: {
      description: 'New <span class="provider">customer</span> in <span class="provider">Magento</span>',

      type: :paging_desc,
      
      input_fields: lambda do |object_definition|
        object_definition['customer'].
          only('created_at').
          required('created_at')
      end,
      
      poll: lambda do |connection, input, page|
        page_size = 100

        param = {
          'searchCriteria' => {
            'filterGroups' => {
              '0' => {
                'filters' => {
                  '0' => {
                    'field' => 'created_at',
                    'value' => "#{input['created_at'].to_time.utc.iso8601}",
                    'conditionType' => 'gt'
                  }
                }
              }
            },
            'sortOrders' => {
              '0' => {
                'field' => 'created_at',
                'direction' => 'desc'
              }
            }
          },
          'pageSize' => page_size,
          'currentPage' => (page || 0)
        }
        
        response = get("#{connection['server']}/rest/V1/customers/search", param)
        
        next_page = if response['page_size'].blank? || response['page_size'] < page_size
                      0
                    else
                      response['current_page'] + 1
                    end

        {
          events: response['items'],
          next_page: next_page
        }
      end,
      
      output_fields: lambda do |object_definition|
        object_definition['customer']
      end,

      sample_output: lambda do |connection|
        param = {
          'searchCriteria' => {
            'sortOrders' => {
              '0' => {
                'field' => 'created_at',
                'direction' => 'desc'
              }
            }
          },
          'pageSize' => 1,
        }

        get("#{connection['server']}/rest/V1/customers/search", param)['items'].first || {}
      end
    },
    
    new_purchase_order: {
      description: 'New <span class="provider">purchase order</span> in <span class="provider">Magento</span>',

      type: :paging_desc,
      
      input_fields: lambda do |object_definition|
        object_definition['order'].
          only('created_at').
          required('created_at')
      end,
      
      poll: lambda do |connection, input, page|
        page_size = 100

        param = {
          'searchCriteria' => {
            'filterGroups' => {
              '0' => {
                'filters' => {
                  '0' => {
                    'field' => 'created_at',
                    'value' => "#{input['created_at'].to_time.utc.iso8601}",
                    'conditionType' => 'gt'
                  }
                }
              }
            },
            'sortOrders' => {
              '0' => {
                'field' => 'created_at',
                'direction' => 'desc'
              }
            }
          },
          'pageSize' => page_size,
          'currentPage' => (page || 0)
        }

        response = get("#{connection['server']}/rest/V1/orders", param)

        next_page = if response['page_size'].blank? || response['page_size'] < page_size
                      0
                    else
                      response['current_page'].to_i + 1
                    end

        {
          events: response['items'],
          next_page: next_page
        }
      end,
  
      document_id: lambda do |order|
        order['entity_id']
      end,
      
      output_fields: lambda do |object_definition|
        object_definition['order']
      end,

      sample_output: lambda do |connection|
        param = {
          'searchCriteria' => {
            'sortOrders' => {
              '0' => {
                'field' => 'created_at',
                'direction' => 'desc'
              }
            }
          },
          'pageSize' => 1,
        }

        get("#{connection['server']}/rest/V1/orders", param)['items'].first || {}
      end
    },

    new_or_updated_purchase_order: {
      description: 'New/Updated <span class="provider">purchase order</span> in <span class="provider">Magento</span>',

      type: :paging_desc,
      
      input_fields: lambda do |object_definition|
        object_definition['order'].
          only('updated_at').
          required('updated_at')
      end,
      
      poll: lambda do |connection, input, page|
        page_size = 100

        param = {
          'searchCriteria' => {
            'filterGroups' => {
              '0' => {
                'filters' => {
                  '0' => {
                    'field' => 'updated_at',
                    'value' => "#{input['updated_at'].to_time.utc.iso8601}",
                    'conditionType' => 'gt'
                  }
                }
              }
            },
            'sortOrders' => {
              '0' => {
                'field' => 'updated_at',
                'direction' => 'desc'
              }
            }
          },
          'pageSize' => page_size,
          'currentPage' => (page || 0)
        }

        response = get("#{connection['server']}/rest/V1/orders", param)

        next_page = if response['page_size'].blank? || response['page_size'] < page_size
                      0
                    else
                      response['current_page'].to_i + 1
                    end

        {
          events: response['items'],
          next_page: next_page
        }
      end,

      document_id: lambda do |order|
        order['entity_id']
      end,

      sort_by: lambda do |order|
        order['updated_at']
      end,

      output_fields: lambda do |object_definition|
        object_definition['order']
      end,

      sample_output: lambda do |connection|
        param = {
          'searchCriteria' => {
            'sortOrders' => {
              '0' => {
                'field' => 'created_at',
                'direction' => 'desc'
              }
            }
          },
          'pageSize' => 1,
        }

        get("#{connection['server']}/rest/V1/orders", param)['items'].first || {}
      end
    }
  }
}
