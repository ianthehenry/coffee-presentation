module.exports = (grunt) ->
  grunt.loadNpmTasks 'grunt-contrib-handlebars'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-shell'

  grunt.initConfig
    handlebars:
      options:
        processName: (filename) -> 
          [path..., name, extension] = filename.split(/\.|\//)
          return name
        partialsPathRegex: /.*/
        partialRegex: /.*/
        partialsUseNamespace: true
        processContent: (content) ->
          content = content.replace(/^\s+/mg, '')
          content = content.replace(/\s+$/mg, '')
          content = content.replace(/\n/g, '')
          return content
      compile:
        files:
          'out/templates.js': 'client/templates/*.hbs'
    stylus:
      compile:
        files:
          'out/main.css': 'client/styles/main.styl'
    coffee:
      compile:
        files:
          'out/main.js': 'client/coffee/main.coffee'
    concat:
      compile:
        files:
          'out/all.js': ['client/js/underscore-min.js', 'client/js/jquery-2.0.1.min.js', 'node_modules/handlebars/dist/handlebars.runtime.js', 'client/js/coffee-script.js', 'client/js/backbone-min.js', 'out/templates.js', 'out/main.js']
    copy:
      compile:
        files:
          'client/static/all.js': 'out/all.js'
          'client/static/main.css': 'out/main.css'
    shell:
      focus: 
        command: "osascript -e 'tell application \"Google Chrome\" \n tell active tab of first window \n reload \n end tell \n activate \n end tell'"
      restartnode: 
        command: "osascript -e 'tell application \"iTerm\" \n activate \n tell the current terminal \n tell the current session \n write text (character id 3) & \"coffee server.coffee\" \n end tell \n end tell \n end tell \n'"
      sleep:
        command: "sleep 0.3"

  grunt.registerTask 'all.js', ['handlebars', 'coffee', 'concat']
  grunt.registerTask 'default', ['all.js', 'stylus', 'copy']
  grunt.registerTask 'magic', ['default', 'shell:restartnode', 'shell:sleep', 'shell:focus']
