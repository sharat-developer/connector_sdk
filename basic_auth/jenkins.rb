{
  title: 'Jenkins',

  connection: {
    fields: [
      {
        name: 'subdomain',
        control_type: 'subdomain',
        hint: 'Your port address'
      },
      {
        name: 'username',
        optional: true,
        hint: 'Your username'
      },
      {
        name: 'password',
        control_type: 'password',
        label: 'Password or API key',
        hint: 'Your password or Api key'
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

  test: ->(connection) {
    get("http://#{connection['subdomain']}/asynchPeople/api/json")
  },

  actions: {
    create_build: {

      description: 'Create <span class="provider"> build </span> in <span class="provider">Jenkins</span>',

      input_fields: ->() {[
        { name: 'job', label: 'JOB NAME', optional: false}]
      },

      execute: ->(connection, input) {
        post("http://#{connection['subdomain']}/job/#{input['job']}/build", input)
      },
      },
  },

  triggers: {
    new_job: {

      description: 'New <span class="provider"> job </span> in <span class="provider">Jenkins</span>',

      input_fields: ->() {
        []
      },
      poll: ->(connection, input, last_updated_since) {
        updated_since = last_updated_since

        jobs = get("http://#{connection['subdomain']}/view/All/api/json?pretty=true")['jobs']

        next_updated_since = jobs.last['name'] unless jobs.blank?

        {
          events: jobs,
          next_poll: next_updated_since,
          can_poll_more: jobs.length >= 50
        }
      },
      dedup: ->(job) {
        job['name']
      },
      output_fields: ->() {
      [
        { name: '_class' },
        { name: 'name' },
        { name: 'url' },
        { name: 'color' }
      ]
      },
      sample_output: ->(connection) {
       get("http://#{connection['subdomain']}/view/All/api/json?pretty=true")['jobs'].first || []
      }
    },
  }
}
