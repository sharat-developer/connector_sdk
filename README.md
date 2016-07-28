[![Workato](images/workato_logo.png)](https://www.workato.com)

# Introduction

Welcome to the Workato Developer Program website. Here you will find the documentation you need to build application adapters using our SDK. If you are interested in applying to the Developer Program, click on the link below to sign up.

## [Sign Up Here](http://bit.ly/WorkatoSDKRequest)

Also, Workato offers a [HTTP Connector](http://bit.ly/WorkatoHTTPConnector) where you can create your own app connectors without having to code.

## Recipe

A Workato recipe is a set of predefined instructions to be executed. It is made up of a trigger and one or more actions.

It execute a variety of tasks to all the applications supported by the Workato platform.

## Trigger

Defines an event that triggers the execution of a Workato recipe

## Action

Steps that will be executed when a recipe is triggered.

There are 4 types of actions:

1.  **Action**
  - Basic actions perform tasks like Search, Create, Update
2. **Conditional action**
  - These actions behave like traffic control. They provide users with the capability to restrict certain actions based on conditions.
  - Example: Create a new Account only if it does not already exist
3. **Repeat action**
  - Repeat actions are simple loops. They perform predefined tasks multiple times based on an array (list) of records.
  - Example: Add line items in QuickBooks for each opportunity item in Salesforce
4. **Stop**
  - Allows users to terminate a run of the recipe (a job). This is useful if you wish to stop performing any actions if a certain condition is met.
  - Optionally, you can define an error for this action. What this does is let you generate exceptions in certain scenarios. These jobs that stops with errors will show up in job history as errors

## Adapter

An Adapter is a connector to an application. Each Adapter has one or more trigger and actions. When an action or trigger is executed, it performs it's respective function with the account instance connected to that application.

# Connector SDK

## Custom Adapters

Connectors, also known as **custom adapters** built on the SDK have private scope. This means that the functions made available by this will only be visible to the workato account.

To enable global scope for this connector, please submit a pull request to our [repository](https://github.com/workato/connector_sdk).

## Requirements

### REST Architecture

Presently, only RESTful APIs are supported by the Connector SDK.

### JSON Format

Presently, only JSON type data is supported by the Connector SDK.

### Bonus

#### Pagination

Pagination helps with response data that is more manageable. It is definitely a bonus if the intended API supports that.

#### Query

It is very useful to be able to query resources instead of locating them based on IDs. With Search by query, the API allows you to return a list of results that matches your field criterias. You may also want to look out for the ability to query based on created/updated time which will be crucial when building out your triggers.

## Authentication

### Basic Authentication

#### Standard

Typically, a basic authentication requires a username and password combination when making requests. Make sure to include those two fields in the connection fields definition.

```ruby
connection: {

  fields: [
    {
      name: 'username',
      optional: true,
      hint: 'Your email used for login'
    },
    {
      name: 'password',
      control_type: 'password',
    }
  ],

  authorization: {
    type: 'basic_auth',

    credentials: ->(connection) {
      user(connection['username'])
      password(connection['password'])
    }
  }
}
```

To set up a basic authentication, simply define type: ‘basic_auth’ and include the appropriate values in `user()` and `password()` in the credentials section.

#### Variations

Some APIs expect different conventions from a standard basic authentication.

```ruby
connection: {

  fields: [
    {
      name: 'api_key',
      optional: false,
      hint: 'Profile (top right) > Settings > Your API Keys'
    }
  ],

  authorization: {
    type: 'basic_auth',

    # close.io uses api key only for authentication. treats apikey as username and password left blank
    # curl -u "{your api_key}:" "https://app.close.io/api/v1/me/"
    credentials: ->(connection) {
      user(connection['api_key'])
      password("")
    }
  }
}
```

In this example Close.io API expects an API Key generated inthe individual User’s account. It should be used as a username with a blank password in the standard basic authentication format.

So, to adjust the connections portion of the code to suit this behaviour, simply request for an API instead of username + password.

In the credentials section, pass the api_key into `user()` and an empty string (“”) to `password()`

```ruby
connection: {

  fields: [
    {
      name: 'api_token',
      control_type: 'password',
      label: 'Toggl API token',
      hint: 'Available in "My Profile" page'
    }
  ],

  authorization: {
    type: 'basic_auth',

    # Toggl API expect the token to be sent as user name and the string 'api_token' as the password
    # curl -u "{your api_token}:api_token" "https://www.toggl.com/api/v8/me"
    credentials: ->(connection) {
      user(connection['api_token'])
      password('api_token')
    }
  }
}
```

Another variation is to have a generated api_token replace the user name and have the string “api_token” replacing password in the basic authentication format.

### API Key Authentication

For APIs that expect API Key authentication, it is a slight variation from the basic authentication code above.

Make sure to include the required inputs from the user (subdomain, api_key, scope etc)

Define
1. type: ‘api_key’
2. the appropriate parameter name for the api_key. In this case, it is simple “api_key”

After defining this, calls will have the appropriate params appended.

Example:
`\<BASE_URL>/users?api_key=NB674921`

```ruby
connection: {

  fields: [
    {
      name: 'helpdesk',
      control_type: 'subdomain',
      url: '.freshdesk.com',
      hint: 'Your helpdesk name as found in your Freshdesk URL'
    },
    {
      name: 'api_key',
      control_type: 'password',
      label: 'API key'
    }
  ],

  authorization: {
    type: 'api_key',

    credentials: ->(connection) {
      params(api_key: connection['api_key'])
    }
  }
}
```

### OAuth 2.0

For a more secure method of authentication, we recommend using OAuth 2.0. It is an open standard and is generally a more secure way for users to log into third party websites without exposing their credentials.

```ruby
connection: {

  authorization: {
    type: 'oauth2',

    authorization_url: ->() {
      'https://www.pushbullet.com/authorize?response_type=code'
    },

    token_url: ->() {
      'https://api.pushbullet.com/oauth2/token'
    },

    client_id: 'YOUR_PUSHBULLET_CLIENT_ID',

    client_secret: 'YOUR_PUSHBULLET_CLIENT_SECRET',

    credentials: ->(connection, access_token) {
      headers('Authorization': "Bearer #{access_token}")
    }
  }
}
```

The Workato connector SDK currently supports the authorization code grant variant of the OAuth2 standard.

Required components in OAuth 2.0 type connection
1. Type (use ‘oauth2’)
2. Authorization_url
3. Token_url
4. Client_id and client_secret
5. Credentials

Redirect URI will be appended to the authorization request by the framework, so there is no need to include it. If the application requires that you register the redirect URI beforehand, use:
https://www.workato.com/oauth/callback

Adjust headers format as required in the credentials section

For example, Pushbullet expects the header to include token in this format:
`OAuth2: \<access token>`

So to adjust to suit this requirement, define the credentials portion like so:

```ruby
connection: {

  authorization: {
    type: 'oauth2',

    authorization_url: ->() {
      'https://podio.com/oauth/authorize'
    },

    token_url: ->() {
      'https://podio.com/oauth/token'
    },

    client_id: 'YOUR_PODIO_CLIENT_ID',

    client_secret: 'YOUR_PODIO_CLIENT_SECRET',

    credentials: ->(connection, access_token) {
      headers('Authorization': "OAuth2 #{access_token}")
    }
  }
}
```

Note:
SDK makes a POST request to token endpoint. Will not currently work for APIs expecting a different type of request.

## Action

### Endpoints

An action can make one or more requests to various endpoints. Because the framework handles the authentication side of a request, you will not have to worry about that here.

The most important thing is to identify which endpoint will address the purpose of the action. Here we will take a look at Close.io’s Lead object and how to retrieve it via the API

![close.io get lead object image](images/closeio-doc.png)

```ruby
actions: {

  get_lead_by_id: {

    input_fields: ->() {
      [
        { name: "lead_id", optional: false }
      ]
    },

    execute: ->(connection, input) {
      get("https://app.close.io/api/v1/lead/#{input['lead_id']}/")
    },

    output_fields: ->(object_definitions) {
      object_definitions['lead']
    }
  }
}
```

A very simple action looks like this. A get request to the Close.io leads endpoint. In this case, the particular lead’s details is appended in the endpoint.

### Parameter / Payload

Other endpoints require parameters to access certain details, instead of accessing a particular resource route.

A GET request can have parameters added to the request like so:

```ruby
execute: ->(connection, input) {
  {
    'companies': get("https://#{connection['deployment']}.api.accelo.com/api/v0/companies.json").
                 params(_search: input['company_name'])['response']
  }
}
```

A POST or PUT or PATCH request can have payloads attached as well. There are 2 ways you can do this.

Add payloads to the method

```ruby
execute: ->(connection, input) {
  {
    'users': get("https://#{connection['helpdesk']}.freshdesk.com/api/users.json", input)['results']
  }
}
```

Add payloads using the payload method

```ruby
execute: ->(connection,input) {
  post("https://api.pushbullet.com/v2/pushes").
    payload(email: input['email'],
            title: input['title'],
            body: input['body'])
}
```

### Methods

Not all ruby public instance methods are available. Methods are whitelisted to ensure security. The Workato SDK Framework also exposes some methods to make building SDKs convenient.


Here is a list of methods available:

REST verb methods (inputs are expected to be in JSON format)
- get(url)
- post(url, input)
- put(url, input)
- patch(url, input)

Ruby methods
- each
- group_by
- headers
- ignored
- inject
- iso8601
- lambda
- map
- merge
- only
- params
- password
- payload
- pluck
- rand
- reject
- required
- select
- sort
- sort_by
- user
- utc
- puts (ruby’s console.log/stdout, not the same as put)
- while

(I may have missed some, feel free to contact [me](eeshan@workato.com) to update this list)

## Trigger

```ruby
triggers: {
  new_company: {

    type: :paging_desc,

    input_fields: ->() {
      [
        { name: 'created_after', type: :timestamp, optional: false }
      ]
    },

    poll: ->(connection, input, last_created_since) {
      created_since = (last_created_since || input['created_after'] || Time.now).to_i # Accelo expects Unix Time Stamp

      companies = get("https://#{connection['deployment']}.api.accelo.com/api/v0/companies.json").
                 params(_filters: "date_created_after(#{created_since})",
                        _limit: 2,
                        _fields: 'date_created,website,status,phone,fax')['response']

      next_created_since = companies.last['date_created'] unless companies.blank?

      {
        events: companies,
        next_page: next_created_since
      }
    },

    dedup: ->(company) {
      company['id']
    },

    output_fields: ->(object_definitions) {
      object_definitions['company']
    }
  }
}
```

### type (optional)

`:paging_desc` - Descending order feature that sorts events (below)

### poll

Poll block is where you can define the behaviour of the trigger. It accepts [ruby syntax](http://ruby-doc.org/).

`since` - This parameter acts as a filter for the trigger. Typically, it is a datetime type data that tells the trigger to pick up events/records after a certain date and time.

It is usually a datetime type data. It can also take on record IDs, assuming that IDs are always incremental.

Order: SDK supports ascending or descending order in requests

### events

Array of records to be processed. Each event should be a record to be processed in the recipe.

### next_poll / next_page

This is a nifty feature that allows the Workato Trigger Framework to recognise the last poll state. This will be used in consecutive polls to ensure that no data is re-polled.

This value is passed to the next poll as the `Since` parameter.

### can_poll_more (optional)

This is a boolean type component. It tells the Workato Trigger Poll Framework whether to trigger another poll. It is typically used to mark if there are more “pages” of records to be picked up.

### dedup

Dedup component is basically to identify individual records. This component is given the parameter “event”, which corresponds to individual items in the array passed into “Events”.

A typical dedup input is event[‘id’] where event is replaced make the code more readable.

In this case, the trigger handles leads. Individual leads can be identified by their unique ids lead[‘id’].

## Webhook Trigger

```ruby
triggers: {
  new_message: {
    type: :paging_desc,

    input_fields: ->(object_definitions) {
      object_definitions['room'].only('id')
    },

    webhook_subscribe: ->(webhook_url, connection, input, flow_id) {
      post('https://api.ciscospark.com/v1/webhooks',
           name: "Workato recipe #{flow_id}",
           targetUrl: webhook_url,
           resource: 'messages',
           event: 'created',
           filter: "roomId=#{input['id']}")
    },

    webhook_notification: ->(input, payload) {
      payload['data']
    },

    webhook_unsubscribe: ->(webhook) {
      delete("https://api.ciscospark.com/v1/webhooks/#{webhook['id']}")
    },

    dedup: ->(message) {
      message['id']
    },

    output_fields: ->(object_definitions) {
      object_definitions['message']
    }
  }
}
```

### webhook_subscribe

This block is called when the recipe is being started to run necessery API calls to subscribe for further webhook notifications. The endpoint that supposed to be register is passed in `webhook_url` parameter with other data that could be useful while registering the webhook.

### webhook_unsubscribe

This block will be called after recipe start to unsubscribe from webhook notifications.

### webhook_notification

POST/PUT HTTP requests can be used to notify about new trigger events. JSON-encoded payload is expected. This block is called to extract trigger output data from webhook notification payload (`payload` attribute). Original trigger input is also available in this block (`input` attribute)

## Object Definition

Object Definitions is an important component of the SDK. It allows you to define your schema for objects to be used in the actions and triggers. It allows you to easily define outputs and inputs later on.

### Static Definition

The most basic way to build an object definition is to define the field name and type

```ruby
object_definitions: {
  push: {
    fields: ->() {
      [
        { name: 'active', type: :boolean },
        { name: 'body' },
        { name: 'created' },
        { name: 'direction' },
        { name: 'dismissed', type: :boolean },
        { name: 'iden' },
        { name: 'modified' },
        { name: 'receiver_email' },
        { name: 'receiver_email_normalized' },
        { name: 'receiver_iden' },
        { name: 'sender_email' },
        { name: 'sender_email_normalized' },
        { name: 'sender_iden' },
        { name: 'sender_name' },
        { name: 'title' },
        { name: 'type' },
      ]
    }
  }
}
```

In this example, the object “Push” is being defined in the fields lambda literal `->()`

Defined as an array of objects. Each field object corresponds to a field in the comment object.

### Dynamic Definition

```ruby
object_definitions: {

  form: {
    fields: ->(connection) {
      get("https://api.unbounce.com/pages/#{connection['page_id']}/form_fields")['formFields'].
        map { |field| { name: field['id'] } }
    }
  }
}
```

### Components

Key | Definition
--- | ----------
name | The name of this field. For example `id` or `created_at`
type | The data type of this field. Default value is string
control_type | The input field type to expose in a recipe.
pick_list | If control type is 'select', this component is  required. See more in **Pick List**
properties | When defining nested objects, use the properties key to define the fields in the object. Remember to define the type as `:array` or `:object`

#### type
It should be given the symbol notation (prepend colon)

Supported types:
`:string`, `:integer`, `:datetime`, `:date`, `:boolean`, `:object`, `:array`

`:object`, and `:array` must be accompanied with properties

#### control_type

Some of the available values are
url: the data field will show a link
select: the data field will be a pick list (make sure to include the pick_list property

Other supported types:
timestamp, checkbox, phone, email, text, number, text-area

## Test

Test endpoint to ensure that connection is successful.

Typically, this should be a request that will always be accessible to any user.

Here are some examples:

```ruby
test: ->(connection) {
  get("https://person.clearbit.com/v1/people/email/eeshansim@gmail.com")
}
```

```ruby
test: ->(connection) {
  get("https://app.clicktime.com/api/1.3/session")
}
```

## Pick List
A pick list is list of choices predefined for a user to select instead of having to input the actual values.
It is useful when there is a list of accepted values for a field or when the field requires a value that is not visible. For example, a field that requires User ID will require a pick list that displays the User names and pass the corresponding User's ID to that field.

### Defining a pick list
There are 2 ways to define a pick list: dynamically or statically.

Static example:

Pick list is defined as a array of selections. Each selection is an array made up of 2 elements.

The first element in the selection array is the value displayed and the second element is the value of that selection.
```ruby
pick_lists: {
  folder: ->(connection) {
    [
      ["Root","111390"],
      ["Recycle Bin","235611"]
    ]
  }
}
```

Dynamic example:
```ruby
pick_lists: {
  folder: ->(connection) {
    get("https://www.wrike.com/api/v3/folders")['data'].
      map { |folder| [folder['title'], folder['id']] }
  }
}
```
After making a GET requests for all folders available, the pick list is populated with folder `id`s and displays the corresponding folder `title`

### Usage
```ruby
input_fields: ->(object_definitions) {
  [
    { name: 'folder_id', control_type: 'select', pick_list: 'folder' }
  ]
}
```

# Example Adapters

## Basic Authentication Samples
- [Harvest app connector](https://github.com/workato/connector_sdk/blob/master/basic_auth/harvest_connector.rb)

- [Freshdesk connector](https://github.com/workato/connector_sdk/blob/master/basic_auth/freshdesk_connector.rb)

- [Clearbit connector](https://github.com/workato/connector_sdk/blob/master/basic_auth/clearbit_connector.rb)

- [Close.io connector](https://github.com/workato/connector_sdk/blob/master/basic_auth/close_io_connector.rb)

- [Click Time connector](https://github.com/workato/connector_sdk/blob/master/basic_auth/click_time_connector.rb)

- [Toggl connector](https://github.com/workato/connector_sdk/blob/master/basic_auth/toggl_connector.rb)

- [Unbounce connector](https://github.com/workato/connector_sdk/blob/master/basic_auth/unbounce_connector.rb)

- [Watson Tone Analyzer connector](https://github.com/workato/connector_sdk/blob/master/basic_auth/watson_tone_analyzer_connector.rb)

## OAuth2 Samples
- [Podio connector](https://github.com/workato/connector_sdk/blob/master/oauth2/podio_connector.rb)

- [ProductHunt connector](https://github.com/workato/connector_sdk/blob/master/oauth2/producthunt_connector.rb)

- [Accelo connector](https://github.com/workato/connector_sdk/blob/master/oauth2/accelo_connector.rb)

- [Pushbullet connector](https://github.com/workato/connector_sdk/blob/master/oauth2/pushbullet_connector.rb)

- [Wrike connector](https://github.com/workato/connector_sdk/blob/master/oauth2/wrike_connector.rb)

- [Cisco Spark connector](https://github.com/workato/connector_sdk/blob/master/oauth2/cisco_spark_connector.rb)

## API Key Authentication Samples
- [Gender API connector](https://github.com/workato/connector_sdk/blob/master/api_key_auth/gender_api_connector.rb)

## Custom Authentication Samples
- [LoJack app connector](https://github.com/workato/connector_sdk/blob/master/custom_auth/lo_jack_connector.rb)

- [SafetyCulture app connector](https://github.com/workato/connector_sdk/blob/master/custom_auth/safetyculture_connector.rb)

- [Knack HQ connector](https://github.com/workato/connector_sdk/blob/master/custom_auth/knack_hq_connector.rb)
