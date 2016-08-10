
  {
  title: 'targetprocess',
  
  connection: {
    fields: [
      {
        name: 'company',
        control_type:'subdomain',
        url: '.tpondemand.com',
        hint: 'Your company name as found in your Targetprocess URL'
      },
      {
        name: 'username',
        optional: false,
        hint: 'Your username'
      },
      {
        name: 'password',
        control_type: 'password',
        optinoal: false,
        label: 'Password'
      }
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

    project: {
      
      preview: ->(connection) {
        get("https://#{connection['company']}.tpondemand.com/api/v1/Projects?format=json")
      },
      
      fields: ->() {
        [
          {name: 'Id'},
          {name: 'Name'},
          {name: 'Description'},
          {name: 'StartDate',type: :timestamp},
          {name: 'CreateDate',type: :timestamp},
          {name: 'ModifyDate',type: :timestamp},
          {name: 'Tags'},
          {name: 'NumericPriority',type: :decimal},
          {name: 'IsNow',type: :boolean},
          {name: 'IsNext',type: :boolean},
          {name: 'IsPrevious',type: :boolean},
          {name: 'IsActive',type: :boolean},
          {name: 'IsProduct',type: :boolean},
          {name: 'Abbreviation'},
          {name: 'MailReplyAddress'},
          {name: 'Color',hint: 'Please enter the hexadecimal value for color'},
          {name: 'IsPrivate',type: :boolean},
          {name: 'Units'} 
        ]
      },
    },
   
   userstory: {
     
     preview: ->(connection) {
        get("https://#{connection['company']}.tpondemand.com/api/v1/UserStories?format=json")
      },
     
     fields: ->(){
       [
          {name:'Id'},
          {name: 'Name'},
          {name: 'Description'},
          {name: 'StartDate',type: :timestamp},
          {name: 'CreateDate',type: :timestamp},
          {name: 'ModifyDate',type: :timestamp},
          {name: 'Tags'},
          {name: 'NumericPriority',type: :decimal},
          {name: 'IsNow',type: :boolean},
          {name: 'IsNext',type: :boolean},
          {name: 'IsPrevious',type: :boolean},
          {name: 'IsActive',type: :boolean},
          {name: 'IsProduct',type: :boolean},
          {name: 'Units'} 
         ]
       },
     },
 
   },
  
 actions: {
   
  create_project: {
      
    description: 'Create <span class="provider">project</span> in <span class="provider">targetprocess</span>',
      
    input_fields: ->(object_definitions) {
        object_definitions['project'].ignored('Id','CreateDate','ModifyDate').required('Name')
      },

    execute: ->(connection, input) {
        post("https://#{connection['company']}.tpondemand.com/api/v1/Projects?",input)
      },

    output_fields: ->(object_definitions) {
        object_definitions['project']
      }
    },
    
  update_project:{
    
    description: 'Update <span class="provider">project</span> in <span class="provider">targetprocess</span>',
    
    input_fields: ->(object_definitions){
      object_definitions['project'].required('Id').ignored('CreateDate','ModifyDate')
      },
    
    execute: ->(connection,input){
      post("https://#{connection['company']}.tpondemand.com/api/v1/Projects",input)['project']
      },
    
    output_fields: ->(object_definitions){
      object_definitions['project']
      },
    },
  
  delete_project:{
    
    description: 'Delete <span class="provider">project</span> in <span class="provider">targetprocess</span>',
    
    input_fields: ->(){[
      {name: 'Id',hint: ': Please Enter your Project Id',optional: false}
      ]
    },
     
    execute: ->(connection,input){
      delete("https://#{connection['company']}.tpondemand.com/api/v1/Projects/#{input['Id']}")
      },
     
    output_fields: ->(object_definitions){
      object_definitions['project']
      }
     },
   
   create_task: {
      
     description: 'Create <span class="provider">task</span> in <span class="provider">targetprocess</span>',
      
     input_fields: ->() {

       [ 
        {name:'project_id',type: :integer,optional: false},
        {name:'userstory_id',type: :integer,optional: false},
        {name:'Name',optional: false}
       ]
     },
  
     execute: ->(connection, input) {
       hash = {
              "project" => {'Id' => input['project_id']},
              "userstory" => {'Id' => input['userstory_id']},
              "Name" => input['Name']
         }

     post("https://#{connection['company']}.tpondemand.com/api/v1/Tasks?format=json",hash)
      },

      output_fields: ->(object_definitions) {
            object_definitions['userstory']
      }
    },
   
  update_task:{
    
    description: 'Update <span class="provider">task</span> in <span class="provider">targetprocess</span>',
    
    input_fields: ->(object_definitions){
      object_definitions['userstory'].required('Id').ignored('CreateDate','ModifyDate')
      },
    
    execute: ->(connection,input){
      post("https://#{connection['company']}.tpondemand.com/api/v1/Tasks?format=json",input)['task']
      },
    
    output_fields: ->(object_definitions){
      object_definitions['userstory']
      },
    },
   
   delete_task:{
    
    description: 'Delete <span class="provider">task</span> in <span class="provider">targetprocess</span>',
    
    input_fields: ->(){[
      {name: 'Id',hint: ': Please Enter your Task Id',optional: false}
      ]
    },
     
    execute: ->(connection,input){
      delete("https://#{connection['company']}.tpondemand.com/api/v1/Tasks/#{input['Id']}")
      },
     
    output_fields: ->(object_definitions){
      object_definitions['userstory']
      }
     },
   
    create_userstory: {
      
     description: 'Create <span class="provider">userstory</span> in <span class="provider">targetprocess</span>',
      
     input_fields: ->(object_definitions) {
       [ 
        {name:'project_id',type: :integer,optional: false},
        {name:'Name',optional: false}
       ]
       },
  
     execute: ->(connection, input) {
         hash = {
               "project" => {'Id' => input['project_id']},
               "Name" => input['Name']
          }
            
            post("https://#{connection['company']}.tpondemand.com/api/v1/UserStories?format=json",hash)
      },

     output_fields: ->(object_definitions) {
            object_definitions['userstory']
      }
    },
   
       
  update_userstory:{
    
    description: 'Update <span class="provider">userstory</span> in <span class="provider">targetprocess</span>',
    
    input_fields: ->(object_definitions){
      object_definitions['userstory'].required('Id').ignored('CreateDate','ModifyDate')
      },
    
    execute: ->(connection,input){
      post("https://#{connection['company']}.tpondemand.com/api/v1/UserStories?format=json",input)['bug']
      },
    
    output_fields: ->(object_definitions){
      object_definitions['userstory']
      },
    },
   
   delete_userstory:{
    
    description: 'Delete <span class="provider">userstory</span> in <span class="provider">targetprocess</span>',
    
    input_fields: ->(){[
      {name: 'Id',hint: ': Please Enter your Bug Id',optional: false}
      ]
    },
     
    execute: ->(connection,input){
      delete("https://#{connection['company']}.tpondemand.com/api/v1/UserStories/#{input['Id']}")
      },
     
    output_fields: ->(object_definitions){
      object_definitions['userstory']
      }
     },
   
   create_bug: {
      
      description: 'Create <span class="provider">bug</span> in <span class="provider">targetprocess</span>',
      
      input_fields: ->(object_definitions) {
       [ 
        {name:'project_id',type: :integer,optional: false},
        {name:'Name',optional: false}
       ]
       },
  
      execute: ->(connection, input) {
         hash = {
               "project" => {'Id' => input['project_id']},
               "Name" => input['Name']
          }
            post("https://#{connection['company']}.tpondemand.com/api/v1/Bugs?format=json",hash)
      },

      output_fields: ->(object_definitions) {
            object_definitions['userstory']
      }
    },
   
       
  update_bug:{
    
    description: 'Update <span class="provider">bug</span> in <span class="provider">targetprocess</span>',
    
    input_fields: ->(object_definitions){
      object_definitions['userstory'].required('Id').ignored('CreateDate','ModifyDate')
      },
    
    execute: ->(connection,input){
      post("https://#{connection['company']}.tpondemand.com/api/v1/Bugs?format=json",input)['bug']
      },
    
    output_fields: ->(object_definitions){
      object_definitions['userstory']
      },
    },
   
   delete_bug:{
    
    description: 'Delete <span class="provider">bug</span> in <span class="provider">targetprocess</span>',
    
    input_fields: ->(){[
      {name: 'Id',hint: ': Please Enter your Bug Id',optional: false}
      ]
    },
     
    execute: ->(connection,input){
      delete("https://#{connection['company']}.tpondemand.com/api/v1/Bugs/#{input['Id']}")
      },
     
    output_fields: ->(object_definitions){
      object_definitions['userstory']
      }
     },
   
   create_feature: {
      
     description: 'Create <span class="provider">feature</span> in <span class="provider">targetprocess</span>',
      
     input_fields: ->(object_definitions) {

       [ 
        {name:'project_id',type: :integer,optional: false},
        {name:'Name',optional: false}
       ]
       },
  
     execute: ->(connection, input) {
        hash = {
                  "project" => {'Id' => input['project_id']},
                  "Name" => input['Name']
            }
            post("https://#{connection['company']}.tpondemand.com/api/v1/Features?format=json",hash)
      },

     output_fields: ->(object_definitions) {
            object_definitions['userstory']
      }
    },
   
   update_feature:{
    
    description: 'Update <span class="provider">feature</span> in <span class="provider">targetprocess</span>',
    
    input_fields: ->(object_definitions){
      object_definitions['userstory'].required('Id').ignored('CreateDate','ModifyDate')
      },
    
    execute: ->(connection,input){
      post("https://#{connection['company']}.tpondemand.com/api/v1/Features?format=json",input)['feature']
      },
    
    output_fields: ->(object_definitions){
      object_definitions['userstory']
      },
    },
   
    delete_feature:{
    
    description: 'Delete <span class="provider">feature</span> in <span class="provider">targetprocess</span>',
    
    input_fields: ->(){[
      {name: 'Id',hint: ': Please Enter your Feature Id',optional: false}
      ]
    },
     
    execute: ->(connection,input){
      delete("https://#{connection['company']}.tpondemand.com/api/v1/Features/#{input['Id']}")
      },
     
    output_fields: ->(object_definitions){
      object_definitions['userstory']
      }
     },
   
    
  create_request: {
      
    description: 'Create <span class="provider">request</span> in <span class="provider">targetprocess</span>',
      
    input_fields: ->(object_definitions) {

       [ 
        {name:'project_id',type: :integer,optional: false},
        {name:'Name',optional: false}
       ]
       },
  
    execute: ->(connection, input) {
        hash = {
                "project" => {'Id' => input['project_id']},
                "Name" => input['Name']
          }
            post("https://#{connection['company']}.tpondemand.com/api/v1/Requests?format=json",hash)
      },

    output_fields: ->(object_definitions) {
            object_definitions['userstory']
      }
    },
   
   update_request:{
    
    description: 'Update <span class="provider">request</span> in <span class="provider">targetprocess</span>',
    
    input_fields: ->(object_definitions){
      object_definitions['userstory'].required('Id').ignored('CreateDate','ModifyDate')
      },
    
    execute: ->(connection,input){
      post("https://#{connection['company']}.tpondemand.com/api/v1/Requests?format=json",input)['request']
      },
    
    output_fields: ->(object_definitions){
      object_definitions['userstory']
      },
    },
   
   delete_request:{
    
    description: 'Delete <span class="provider">request</span> in <span class="provider">targetprocess</span>',
    
    input_fields: ->(){[
      {name: 'Id',hint: ': Please Enter your Request Id',optional: false}
      ]
    },
     
    execute: ->(connection,input){
      delete("https://#{connection['company']}.tpondemand.com/api/v1/Requests/#{input['Id']}")
      },
     
    output_fields: ->(object_definitions){
      object_definitions['userstory']
      }
     },
    },
  
 triggers: {
   
   new_project:{
      
     description: 'New <span class="provider">project</span> in <span class="provider">targetprocess</span>',
      
     type: :paging_desc,
      
     input_fields: ->(){
        [
        { name: 'CreateDate', type: :timestamp, optional: false }
        ]
      },
      
     poll: ->(connection,input,last_created_since) {
       created_since = (last_created_since || input['CreateDate'].to_time.utc.iso8601|| Time.now.to_time.utc.iso8601)
       
       projects = get("https://#{connection['company']}.tpondemand.com/api/v1/Projects?format=json&where=(CreateDate gt '#{created_since}')&take=100&skip=0&orderByDesc=CreateDate")
      
       last_created_since =  projects['Items'].last['CreateDate'].to_time.utc.iso8601 unless projects['Items'].blank?
          projects['Items'] = projects['Items'].select do |project|
           project['CreateDate'] == project['ModifyDate']
       end
          {
          events: projects['Items'],
          next_page: last_created_since
        }
      },
      
    document_id: ->(project){
        project['Id']
        },
      
    output_fields: ->(object_definitions) {
        object_definitions['project']
        } 
      },
   
   updated_project:{
      
      description: 'Updated <span class="provider">project</span> in <span class="provider">targetprocess</span>',
      
      type: :paging_desc,
      
      input_fields: ->(){
        [
        { name: 'CreateDate', type: :timestamp, optional: false }
        ]
      },
      
     poll: ->(connection,input,last_created_since) {
       created_since = (last_created_since || input['CreateDate'].to_time.utc.iso8601|| Time.now.to_time.utc.iso8601)
       
       projects = get("https://#{connection['company']}.tpondemand.com/api/v1/Projects?format=json&where=(ModifyDate gt '#{created_since}')&take=100&skip=0&orderByDesc=ModifyDate")
      
       last_created_since =  projects['Items'].last['CreateDate'].to_time.utc.iso8601 unless projects['Items'].blank?
         	 projects['Items'] = projects['Items'].select do |project|
        	  project['CreateDate'] < project['ModifyDate']
       	end

        {
          events: projects['Items'],
          next_page: last_created_since
        }
      },
      
     document_id: ->(project){
        project['Id']
        },
      
     sort_by: ->(project) {
        project['ModifyDate']
      },
    
     output_fields: ->(object_definitions) {
        object_definitions['project']
        } 
      },
   
   new_task:{
      
      description: 'New <span class="provider">task</span> in <span class="provider">targetprocess</span>',
      
      type: :paging_desc,
      
      input_fields: ->(){
        [
        { name: 'CreateDate', type: :timestamp, optional: false }
        ]
      },
      
      poll: ->(connection,input,last_created_since) {
       created_since = (last_created_since || input['CreateDate'].to_time.utc.iso8601|| Time.now.to_time.utc.iso8601)
       
       tasks = get("https://#{connection['company']}.tpondemand.com/api/v1/Tasks?format=json&where=(CreateDate gt '#{created_since}')&take=100&skip=0&orderByDesc=CreateDate")
      
       last_created_since =  tasks['Items'].last['CreateDate'].to_time.utc.iso8601 unless tasks['Items'].blank?
          tasks['Items'] = tasks['Items'].select do |task|
           task['CreateDate'] == task['ModifyDate']
       end
          {
          events: tasks['Items'],
          next_page: last_created_since
        }
      },
      
      document_id: ->(task){
        task['Id']
        },
      
      output_fields: ->(object_definitions) {
        object_definitions['userstory']
        } 
      },
   
   updated_task:{
      
      description: 'Updated <span class="provider">task</span> in <span class="provider">targetprocess</span>',
      
      type: :paging_desc,
      
      input_fields: ->(){
        [
        { name: 'CreateDate', type: :timestamp, optional: false }
        ]
      },
      
      poll: ->(connection,input,last_created_since) {
       created_since = (last_created_since || input['CreateDate'].to_time.utc.iso8601|| Time.now.to_time.utc.iso8601)
       
       tasks = get("https://#{connection['company']}.tpondemand.com/api/v1/Tasks?format=json&where=(ModifyDate gt '#{created_since}')&take=100&skip=0&orderByDesc=ModifyDate")
      
       last_created_since =  tasks['Items'].last['CreateDate'].to_time.utc.iso8601 unless tasks['Items'].blank?
         	 tasks['Items'] = tasks['Items'].select do |task|
        	  task['CreateDate'] < task['ModifyDate']
       	end

        {
          events: tasks['Items'],
          next_page: last_created_since
        }
      },
      
      document_id: ->(task){
        task['Id']
        },
      
      sort_by: ->(task) {
        task['ModifyDate']
      },
    
      output_fields: ->(object_definitions) {
        object_definitions['userstory']
        } 
      },
   
   new_bug:{
      
      description: 'New <span class="provider">bug</span> in <span class="provider">targetprocess</span>',
      
      type: :paging_desc,
      
      input_fields: ->(){
        [
        { name: 'CreateDate', type: :timestamp, optional: false }
        ]
      },
      
      poll: ->(connection,input,last_created_since) {
       created_since = (last_created_since || input['CreateDate'].to_time.utc.iso8601|| Time.now.to_time.utc.iso8601)
       
       bugs = get("https://#{connection['company']}.tpondemand.com/api/v1/Bugs?format=json&where=(CreateDate gt '#{created_since}')&take=100&skip=0&orderByDesc=CreateDate")
      
       last_created_since =  bugs['Items'].last['CreateDate'].to_time.utc.iso8601 unless bugs['Items'].blank?
          bugs['Items'] = bugs['Items'].select do |bug|
           bug['CreateDate'] == bug['ModifyDate']
       end
          {
          events: bugs['Items'],
          next_page: last_created_since
        }
      },
      
      document_id: ->(bug){
        bug['Id']
        },
      
      output_fields: ->(object_definitions) {
        object_definitions['userstory']
        } 
      },
   
   updated_bug:{
      
      description: 'Updated <span class="provider">bug</span> in <span class="provider">targetprocess</span>',
      
      type: :paging_desc,
      
      input_fields: ->(){
        [
        { name: 'CreateDate', type: :timestamp, optional: false }
        ]
      },
      
      poll: ->(connection,input,last_created_since) {
       created_since = (last_created_since || input['CreateDate'].to_time.utc.iso8601|| Time.now.to_time.utc.iso8601)
       
       bugs = get("https://#{connection['company']}.tpondemand.com/api/v1/Bugs?format=json&where=(ModifyDate gt '#{created_since}')&take=100&skip=0&orderByDesc=ModifyDate")
      
       last_created_since =  bugs['Items'].last['CreateDate'].to_time.utc.iso8601 unless bugs['Items'].blank?
         	 bugs['Items'] = bugs['Items'].select do |bug|
        	  bug['CreateDate'] < bug['ModifyDate']
       	end

        {
          events: bugs['Items'],
          next_page: last_created_since
        }
      },
      
      document_id: ->(bug){
        bug['Id']
        },
      
      sort_by: ->(bug) {
        bug['ModifyDate']
      },
    
      output_fields: ->(object_definitions) {
        object_definitions['userstory']
        } 
      },
   
   new_userstory:{
      
      description: 'New <span class="provider">userstory</span> in <span class="provider">targetprocess</span>',
      
      type: :paging_desc,
      
      input_fields: ->(){
        [
        { name: 'CreateDate', type: :timestamp, optional: false }
        ]
      },
      
      poll: ->(connection,input,last_created_since) {
       created_since = (last_created_since || input['CreateDate'].to_time.utc.iso8601|| Time.now.to_time.utc.iso8601)
       
       userstorys = get("https://#{connection['company']}.tpondemand.com/api/v1/UserStories?format=json&where=(CreateDate gt '#{created_since}')&take=100&skip=0&orderByDesc=CreateDate")
      
       last_created_since =  userstorys['Items'].last['CreateDate'].to_time.utc.iso8601 unless userstorys['Items'].blank?
           userstorys['Items'] = userstorys['Items'].select do |userstory|
           userstory['CreateDate'] == userstory['ModifyDate']
       end
          {
          events: userstorys['Items'],
          next_page: last_created_since
        }
      },
      
      document_id: ->(userstory){
        userstory['Id']
        },
      
      output_fields: ->(object_definitions) {
        object_definitions['userstory']
        } 
      },
   
   updated_userstory:{
      
      description: 'Updated <span class="provider">userstory</span> in <span class="provider">targetprocess</span>',
      
      type: :paging_desc,
      
      input_fields: ->(){
        [
        { name: 'CreateDate', type: :timestamp, optional: false }
        ]
      },
      
      poll: ->(connection,input,last_created_since) {
       created_since = (last_created_since || input['CreateDate'].to_time.utc.iso8601|| Time.now.to_time.utc.iso8601)
       
       userstorys = get("https://#{connection['company']}.tpondemand.com/api/v1/Userstories?format=json&where=(ModifyDate gt '#{created_since}')&take=100&skip=0&orderByDesc=ModifyDate")
      
       last_created_since =  userstorys['Items'].last['CreateDate'].to_time.utc.iso8601 unless userstorys['Items'].blank?
         	 userstorys['Items'] = userstorys['Items'].select do |userstory|
        	 userstory['CreateDate'] < userstory['ModifyDate']
       	end

        {
          events: userstorys['Items'],
          next_page: last_created_since
        }
      },
      
      document_id: ->(userstory){
       userstory['Id']
        },
      
      sort_by: ->(userstory) {
       userstory['ModifyDate']
      },
    
      output_fields: ->(object_definitions) {
        object_definitions['userstory']
        } 
      },
   
   new_feature:{
      
      description: 'New <span class="provider">feature</span> in <span class="provider">targetprocess</span>',
      
      type: :paging_desc,
      
      input_fields: ->(){
        [
        { name: 'CreateDate', type: :timestamp, optional: false }
        ]
      },
      
      poll: ->(connection,input,last_created_since) {
       created_since = (last_created_since || input['CreateDate'].to_time.utc.iso8601|| Time.now.to_time.utc.iso8601)
       
       features = get("https://#{connection['company']}.tpondemand.com/api/v1/Features?format=json&where=(CreateDate gt '#{created_since}')&take=100&skip=0&orderByDesc=CreateDate")
      
       last_created_since =  features['Items'].last['CreateDate'].to_time.utc.iso8601 unless features['Items'].blank?
          features['Items'] = features['Items'].select do |feature|
           feature['CreateDate'] == feature['ModifyDate']
       end
          {
          events: features['Items'],
          next_page: last_created_since
        }
      },
      
      document_id: ->(feature){
        feature['Id']
        },
      
      output_fields: ->(object_definitions) {
        object_definitions['userstory']
        } 
      },
   
   updated_feature:{
      
      description: 'Updated <span class="provider">feature</span> in <span class="provider">targetprocess</span>',
      
      type: :paging_desc,
      
      input_fields: ->(){
        [
        { name: 'CreateDate', type: :timestamp, optional: false }
        ]
      },
      
      poll: ->(connection,input,last_created_since) {
       created_since = (last_created_since || input['CreateDate'].to_time.utc.iso8601|| Time.now.to_time.utc.iso8601)
       
       features = get("https://#{connection['company']}.tpondemand.com/api/v1/Features?format=json&where=(ModifyDate gt '#{created_since}')&take=100&skip=0&orderByDesc=ModifyDate")
      
       last_created_since =  features['Items'].last['CreateDate'].to_time.utc.iso8601 unless features['Items'].blank?
         	 features['Items'] = features['Items'].select do |feature|
        	  feature['CreateDate'] < feature['ModifyDate']
       	end

        {
          events: features['Items'],
          next_page: last_created_since
        }
      },
      
      document_id: ->(feature){
        feature['Id']
        },
      
      sort_by: ->(feature) {
        feature['ModifyDate']
      },
    
      output_fields: ->(object_definitions) {
        object_definitions['userstory']
        } 
      },
   
   new_request:{
      
      description: 'New <span class="provider">request</span> in <span class="provider">targetprocess</span>',
      
      type: :paging_desc,
      
      input_fields: ->(){
        [
        { name: 'CreateDate', type: :timestamp, optional: false }
        ]
      },
      
      poll: ->(connection,input,last_created_since) {
       created_since = (last_created_since || input['CreateDate'].to_time.utc.iso8601|| Time.now.to_time.utc.iso8601)
       
       requests = get("https://#{connection['company']}.tpondemand.com/api/v1/Requests?format=json&where=(CreateDate gt '#{created_since}')&take=100&skip=0&orderByDesc=CreateDate")
      
       last_created_since =  requests['Items'].last['CreateDate'].to_time.utc.iso8601 unless requests['Items'].blank?
          requests['Items'] = requests['Items'].select do |request|
           request['CreateDate'] == request['ModifyDate']
       end
          {
          events: requests['Items'],
          next_page: last_created_since
        }
      },
      
      document_id: ->(request){
        request['Id']
        },
      
      output_fields: ->(object_definitions) {
        object_definitions['userstory']
        } 
      },
   
   updated_request:{
      
      description: 'Updated <span class="provider">request</span> in <span class="provider">targetprocess</span>',
      
      type: :paging_desc,
      
      input_fields: ->(){
        [
        { name: 'CreateDate', type: :timestamp, optional: false }
        ]
      },
      
      poll: ->(connection,input,last_created_since) {
       created_since = (last_created_since || input['CreateDate'].to_time.utc.iso8601|| Time.now.to_time.utc.iso8601)
       
       requests = get("https://#{connection['company']}.tpondemand.com/api/v1/Requests?format=json&where=(ModifyDate gt '#{created_since}')&take=100&skip=0&orderByDesc=ModifyDate")
      
       last_created_since =  requests['Items'].last['CreateDate'].to_time.utc.iso8601 unless requests['Items'].blank?
         	 requests['Items'] = requests['Items'].select do |request|
        	  request['CreateDate'] < request['ModifyDate']
       	end

        {
          events: requests['Items'],
          next_page: last_created_since
        }
      },
      
      document_id: ->(request){
        request['Id']
        },
      
      sort_by: ->(request) {
        request['ModifyDate']
      },
    
      output_fields: ->(object_definitions) {
        object_definitions['userstory']
        } 
      },
    }
  }
