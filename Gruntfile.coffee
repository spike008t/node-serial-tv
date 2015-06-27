module.exports = (grunt) ->
  grunt.initConfig {
    mochaTest: {
      specs: {
        options: {
          ui: 'bdd'
          reporter: 'spec'
          require: './spec/helpers/chai.coffee'
        },
        src: ['spec/**/*.spec.coffee']
      }
    }
    watch: {
      files: ['<%= mochaTest.specs.src']
      tasks: ['mochaTest']
    }
  }

  grunt.loadNpmTasks 'grunt-mocha-test'

  grunt.registerTask 'test', ['mochaTest']

  grunt.registerTask 'default', ['test']
