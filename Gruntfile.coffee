# Source: https://coderwall.com/p/j3gxsa
module.exports = (grunt) ->
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-connect')

  grunt.initConfig
    watch:
      coffee:
        files: 'src/*.coffee'
        tasks: ['clean:js', 'coffee:compile']
        options:
          livereload: true

    coffee:
      compile:
        expand: true,
        flatten: true,
        cwd: "#{__dirname}/src/",
        src: ['*.coffee'],
        dest: 'js/',
        ext: '.js'
      options:
        bare: true
        sourceMap: true

    clean:
      js:
        src: ['js']

    connect:
      server:
        options:
          port: 4000,
          base: '',
          hostname: '*'
       
     


  grunt.registerTask 'default',
    'Watches the project for changes, automatically build them',
    ['clean', 'coffee:compile', 'connect', 'watch']
