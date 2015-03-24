'use strict';

var gulp = require('gulp');
var env = require('node-env-file');
env(".env");

var paths = gulp.paths;

var $ = require('gulp-load-plugins')();

gulp.task('scripts', function () {
  return gulp.src(paths.src + '/{app,components}/**/*.coffee')
    .pipe($.replace('PUSHER_APP_KEY', process.env.PUSHER_APP_KEY))
    .pipe($.coffeelint())
    .pipe($.coffeelint.reporter())
    .pipe($.coffee())
    .on('error', function handleError(err) {
      console.error(err.toString());
      this.emit('end');
    })
    .pipe(gulp.dest(paths.tmp + '/serve/'))
    .pipe($.size())
});

