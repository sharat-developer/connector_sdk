{
    title: 'Infobip',
    connection: {
        fields: [
            {
                name: 'api_key',
                control_type: 'password',
                optional: false
            }
        ],
        authorization: {
            type: 'custom_auth',
            credentials: ->(connection) {
              headers(:Authorization => "App #{connection['api_key']}",
                      :'User-Agent' => 'Workato')
            }
        }
    },
    test: ->(connection) {
      get('https://api.infobip.com/sms/1/logs').params(limit: 1)
    },
    object_definitions: {
        send_sms_request: {
            fields: ->() {
              [
                  {name: 'from'},
                  {name: 'to'},
                  {name: 'text'}
              ]
            }
        },
        sent_sms_info: {
            fields: ->() {
              [
                  {name: 'to'},
                  {name: 'status', type: :object, properties: [
                      {name: 'groupId', type: :integer},
                      {name: 'groupName'},
                      {name: 'id', type: :integer},
                      {name: 'name'},
                      {name: 'description'}
                  ]},
                  {name: 'smsCount', type: :integer},
                  {name: 'messageId'}
              ]
            }
        },
        received_sms_info: {
            fields: ->() {
              [
                  {name: 'messageId'},
                  {name: 'from'},
                  {name: 'to'},
                  {name: 'text'},
                  {name: 'cleanText'},
                  {name: 'keyword'},
                  {name: 'smsCount', type: :integer},
                  {name: 'receivedAt', type: :datetime}
              ]
            }
        }
    },
    actions: {
        send_sms: {
            input_fields: ->(object_definitions) {
              object_definitions['send_sms_request'].required('to')
            },
            execute: ->(connection, input) {
              post('https://api.infobip.com/sms/1/text/single', input)['send_sms_request']
            },
            output_fields: ->(object_definitions) {[
                { name: 'messages', type: :array, of: :object, properties: object_definitions['sent_sms_info'] }
            ]}
        }
    },
    triggers: {
        sms_received: {
            poll: ->(connection, input, last_received_at) {
              received_since = (last_received_at || Time.now - 30 * 60).utc.strftime('%Y-%m-%dT%H%%3A%M%%3A%S%%2E%L%%2B00%%3A00')

              received_messages = get("https://api.infobip.com/sms/1/inbox/logs?receivedSince=#{received_since}")

              received_sms_info = received_messages['results']
              last_received_at = received_sms_info.length == 0 ? received_since : received_sms_info[0]['receivedAt']
              {
                  events: received_sms_info.reverse,
                  next_poll: last_received_at
              }
            },
            dedup: ->(received_sms_info) {
              received_sms_info['messageId']
            },
            output_fields: ->(object_definitions) {[
                { name: 'results', type: :array, of: :object, properties: object_definitions['received_sms_info'] }
            ]}
        }
    }
}