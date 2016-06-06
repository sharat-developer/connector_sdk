{
  title: 'Watson Tone Analyzer',

  connection: {
    fields: [
      {
        name: 'username', optional: true,
        hint: 'Your username; leave empty if using API key below'
      },
      {
        name: 'password', control_type: 'password',
        label: 'Password or personal API key'
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
    post("https://gateway.watsonplatform.net/tone-analyzer-beta/api/v3/tone?version=2016-02-11").
      payload(text: "this is it")
  },

  object_definitions: {
    tone: {
      fields: ->(connection) {
        [
          { name: 'score', type: :decimal },
          { name: 'tone_id' },
          { name: 'tone_name' }
        ]
      }
    }
  },

  actions: {
    analyze_content: {
      input_fields: ->(object_definitions) {
        [
          { name: 'text', optional: false }
        ]
      },

      execute: ->(connection, input) {
        response = post("https://gateway.watsonplatform.net/tone-analyzer-beta/api/v3/tone?version=2016-02-11").
                     payload(text: input['text'])['document_tone']
        
        emotional_tones = response['tone_categories'].first
        dominant_emotion_tone = emotional_tones['tones'].sort { |a,b| b['score'] <=> a['score'] }.first
        puts 'emotion'
        
        writing_tones = response['tone_categories'].second
        dominant_writing_tone = writing_tones['tones'].sort { |a,b| b['score'] <=> a['score'] }.first
        puts 'writing'
        
        social_tones = response['tone_categories'].third
        dominant_social_tone = social_tones['tones'].sort { |a,b| b['score'] <=> a['score'] }.first
        puts 'social'
        
        {
          'dominant_emotion_tone': dominant_emotion_tone,
          'emotion_tones': emotional_tones['tones'],
          'dominant_writing_tone': dominant_writing_tone,
          'writing_tones': writing_tones['tones'],
          'dominant_social_tone': dominant_social_tone,
          'social_tones': social_tones['tones'],
        }
      },

      output_fields: ->(object_definitions) {
        [
          { name: 'dominant_emotion_tone', type: :object,
            properties: object_definitions['tone'] },
          { name: 'emotion_tones', type: :array,
            of: :object, properties: object_definitions['tone'] },
          { name: 'dominant_writing_tone', type: :object,
            properties: object_definitions['tone'] },
          { name: 'writing_tones', type: :array,
            of: :object, properties: object_definitions['tone'] },
          { name: 'dominant_social_tone', type: :object,
            properties: object_definitions['tone'] },
          { name: 'social_tones', type: :array,
            of: :object, properties: object_definitions['tone'] },
        ]
      }
    }
  }
}
