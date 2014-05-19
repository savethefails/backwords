# Source: https://coderwall.com/p/j3gxsa
module.exports = (grunt) ->
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-connect')
  grunt.loadNpmTasks('grunt-contrib-copy')

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
        sourceMap: true

    clean:
      default:
        src: ['js', './application.js']
      ghPages:
        src: ['js', 'lib', './application.js.map']

    connect:
      server:
        options:
          port: 4000,
          base: '',
          hostname: '*'

    copy:
      flatten:
        files: [
          # flattens results to a single level
          expand: true
          flatten: true
          src: ['js/**', 'lib/**']
          dest: './'
          filter: 'isFile'
        ]


  grunt.registerTask 'default',
    'Watches the project for changes, automatically build them',
    ['clean:default', 'coffee:compile', 'connect', 'watch']

  grunt.registerTask 'gh-pages',
    'moves files into root for gh-pages setup',
    ['clean:default', 'coffee:compile', 'copy:flatten', 'clean:ghPages']
