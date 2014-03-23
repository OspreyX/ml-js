module.exports = function (grunt) {
    grunt.initConfig({
        mochaTest: {
            test: {
                options: {
                  reporter: 'spec'
                },
                src: ['test/*Spec.js']
            }
        },
        jshint: {   
            all: [ 'gruntfile.js', 'lib/*.js', 'test/*.js'],
            options: {
                globals: {
                    it: true,
                    describe: true,
                    beforeEach: true
                },
                curly: true,
                eqeqeq: true,
                immed: true,
                latedef: true,
                newcap: true,
                noarg: true,
                sub: true,
                undef: true,
                boss: true,
                eqnull: true,
                node: true,
                strict: false,
                es5: true,
                expr: true
            }
        }
    });
    grunt.registerTask('default', ['jshint:all', 'mochaTest']);
    grunt.loadNpmTasks('grunt-contrib-jshint');
    grunt.loadNpmTasks('grunt-mocha-test');    
};