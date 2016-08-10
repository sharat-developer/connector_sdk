{
  title: 'bitbucket',
  
	connection: {
    fields: [   
          { name: "username", optional: false, hint: "Your username", label: "Username" },
         	{ name: "repo_slug", optional: false, hint: "Your repository name", label: "Repository" }
    ],
    authorization: {
      type: 'oauth2',
       authorization_url: ->() {
      	 'https://bitbucket.org/site/oauth2/authorize?response_type=code&scope=issue:write'
       }, 
        token_url: ->() {
         'https://bitbucket.org/site/oauth2/access_token?type=refresh'
       },
      client_id: 'L9QZ4zTGM2HGRvk4Mt',
      client_secret: 'DEqy8WhBn2v7mrNuUk33BufyJnUbSmH4',
      credentials: ->(connection, access_token) {
        headers('Authorization': "Bearer #{access_token}")
      }
    }
  },
  
  test: ->(connection) {    
    get("https://api.bitbucket.org/2.0/user")
  },
  
  object_definitions: {   
    issues: {
      fields: ->() {
        [
          { name: "title", optional: false },
          { name: "description", control_type: 'text-area' },
          { name: "priority", optional: false, control_type: :select, pick_list: "priority" },
          { name: "kind", optional: false, control_type: :select, pick_list: "kind" },
					{ name: "repository", type: :object, properties:[
            { name: "links", type: :object, properties: [
              { name: "self", type: :object, properties: [
              	{ name: "href", type: :url }]},
            	{ name: "html", type: :object, properties: [
              	{ name: "href", type: :url }]},	
            	{ name: "avatar", type: :object, properties: [
              	{ name: "href", type: :url }]},
              ]},
            { name: "type" },
            { name: "name" },
            { name: "full_name" },
            { name: "uuid" }]},
					{ name: "links", type: :object, properties: [
            { name: "self", type: :object, properties: [
              { name: "href", type: :url }]}]},
					{ name: "reporter", type: :object, properties:[
            { name: "username" },
            { name: "display_name" },
           	{ name: "type" },
            { name: "uuid" },
            { name: "links", type: :object, properties: [
              { name: "self", type: :object, properties: [
              	{ name: "href", type: :url }]},
            	{ name: "html", type: :object, properties: [
              	{ name: "href", type: :url }]},	
            	{ name: "avatar", type: :object, properties: [
              	{ name: "href", type: :url }]},
              ]},
            ]},
          { name: "component" },
          { name: "votes", type: :integer },
          { name: "watches", type: :integer },
					{ name: "content", type: :object, properties: [
            { name: "raw" },
            { name: "markup", control_type: :select, pick_list: "markup" },
            { name: "html" }]},
					{ name: "assignee", type: :object, properties:[
            { name: "username" },
            { name: "display_name" },
           	{ name: "type" },
            { name: "uuid" },
            { name: "links", type: :object, properties: [
              { name: "self", type: :object, properties: [
              	{ name: "href", type: :url }]},
            	{ name: "html", type: :object, properties: [
              	{ name: "href", type: :url }]},	
            	{ name: "avatar", type: :object, properties: [
              	{ name: "href", type: :url }]},
              ]},
            ]},
          { name: "status", control_type: :select, pick_list: "state" },
					{ name: "version" },
					{ name: "edited_on", type: :datetime },
          { name: "created_on", type: :datetime },
					{ name: "milestone" },
					{ name: "update_on", type: :datetime },
					{ name: "type" },
					{ name: "id", type: :integer },
          { name: "links", type: :object, properties: [
            { name: "self", type: :object, properties: [
              { name: "href", type: :url }]},
            { name: "repositories", type: :object, properties: [
             	{ name: "href", type: :url }]},
            { name: "html", type: :object, properties: [
             	{ name: "href", type: :url }]},
            { name: "followers", type: :object, properties: [
              { name: "href", type: :url }]},
            { name: "avatar", type: :object, properties: [
              { name: "href", type: :url }]},
            { name: "following", type: :object, properties: [
              { name: "href", type: :url }]}]},
        ]
      }
    },
  },
  
  actions: {
    create_issues: {
      description: 'Create <span class="provider">Issue</span> in <span class="provider">Bitbucket</span>',
      input_fields: ->(object_definitions) {
        object_definitions['issues'].only('title','description','priority','kind')
      },
      execute: ->(connection,input) {
        post("https://api.bitbucket.org/2.0/repositories/#{connection['username']}/#{connection['repo_slug']}/issues",input)
      },
      output_fields: ->(object_definitions) {
        object_definitions['issues']
      }
    },
    
    search_issues: {
      description: 'Search <span class="provider">Issue</span> in <span class="provider">Bitbucket</span>',
      input_fields: ->(object_definitions) {
        [
          { name: "id", type: :integer },
					{ name: "title" },
          { name: "kind" },
					{ name: "priority" },
          { name: "status" }
        ]
      },
      execute: ->(connection,input) {
        c=input.map do |k,v|
          "#{k}=#{v}"
        end.join("&")
        get("https://api.bitbucket.org/1.0/repositories/#{connection['username']}/#{connection['repo_slug']}/issues?#{c}")
      },
      output_fields: ->(object_definitions) {
        object_definitions['issues']
      }
    },
    
    list_comments_in_an_issue_by_issue_id: {
      description: 'List <span class="provider">Comments</span> in <span class="provider">Bitbucket</span>',
      input_fields: ->(object_definitions) {
        [
          { name: "issue_id", type: :integer }
        ]
      },
      execute: ->(connection,input) {
        get("https://api.bitbucket.org/2.0/repositories/#{connection['username']}/#{connection['repo_slug']}/issues/#{input['issue_id']}/comments")
      },
      output_fields: ->(object_definitions) {
        object_definitions['issues']
      }
    },
  },
  
  triggers: {
    new_or_updated_issue: {
      type: :paging_desc,
      input_fields: ->() {
        [
          { name: 'since',
            type: :timestamp }
        ]
      },
      poll: ->(connection,input,last_created_since) {
        updated_since = (last_created_since || input['since'].strftime("%Y-%m-%dT%H:%M:%S") || Time.now)
        response = get("https://api.bitbucket.org/2.0/repositories/#{connection['username']}/#{connection['repo_slug']}/issues?q=created_on>=#{updated_since}")
        next_updated_since = response['values'].last['created_on'] unless response['values'].blank?   
        {
          events: response['values'],
          next_page: response.length >= 100 ? next_updated_since : nil,
        }
      },
      output_fields: ->(object_definitions) {
        object_definitions['issues']
      }
    }, 
  },
  
  pick_lists: {
    markup: ->(connection) {
      [
      ["markdown","markdown"],
      ["creole","creole"],
       ]
    },
    kind: ->(connection) {
      [
        ["bug","bug"],
        ["enhancement","enhancement"],
        ["proposal","proposal"],
        ["task","task"],
        ]
      },
    scm: ->(connection) {
      [
        ["hg","hg"],
        ["git","git"],
        ]
      },
    fork_policy: ->(connection) {
      [
        ["allow_forks","allow_forks"],
        ["no_public_forks","no_public_forks"],
        ["no_forks","no_forks"],
        ]
      },
    priority: ->(connection) {
      [
        ["trivial","trivial"],
        ["minor","minor"],
        ["major","major"],
        ["critical","critical"],
        ["blocker","blocker"],  
        ]
      },
    state: ->(connection) {
      [
        ["new","new"],
        ["open","open"],
        ["resolved","resolved"],
        ["on hold","on hold"],
        ["invalid","invalid"],
        ["duplicate","duplicate"],
        ["wontfix","wontfix"],
        ["closed","closed"],
        ]
      },
}
}
  
