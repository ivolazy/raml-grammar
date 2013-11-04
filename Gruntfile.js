module.exports = function (grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    simplemocha: {
      options: {
        useColors: true,
        ui: 'bdd',
        reporter: 'spec'
      },
      all: ['test/test.coffee']
    },

    watch: {
      files: ['src/**/*.coffee', 'test/**/*.coffee'],
      tasks: ['default']
    },

    browserify: {
      options: {
        transform: ['coffeeify']
      },
      'dist/suggest.js': ['src/suggestion.coffee']
    }
  });

  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-simple-mocha');

  grunt.registerTask('default', ['browserify', 'simplemocha']);

};
