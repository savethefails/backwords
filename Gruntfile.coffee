# Source: https://coderwall.com/p/j3gxsa
module.exports = (grunt) ->
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-connect')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-concat')
  grunt.loadNpmTasks('grunt-contrib-sass')

  grunt.initConfig
    watch:
      coffee:
        files: 'src/*.coffee'
        tasks: ['clean:default', 'coffee:compile']
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
        sourceMap: false

    clean:
      js:
        src: ['js']
      app:
        src: ['./application.js', './application.css']


    concat:
        squash:
          src: ['lib/jquery-2.1.0.min.js', 'js/reverser.js', 'js/ui.js']
          dest: './application.js'

    connect:
      server:
        options:
          port: 4000,
          base: '',
          hostname: '*'

     sass:
      dist:
        options:
          style: 'expanded'
        files:
          'application.css': 'sass/application.scss'


  grunt.registerTask 'default',
    'cleans, compiles, squashes',
    ['clean:js', 'clean:app', 'coffee:compile', 'concat:squash', 'sass:dist', 'clean:js']

  grunt.registerTask 'development',
  'runs tasks for dev environment',
  ['default', 'server']

  grunt.registerTask 'server',
  'creates server and watches',
  ['connect', 'watch']
