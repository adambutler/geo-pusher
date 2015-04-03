'use strict';

var gulp = require('gulp');
var env = require('node-env-file');

try {
  env(".env");
} catch (_error) {
  console.log(_error);
}

var paths = gulp.paths;

var $ = require('gulp-load-plugins')();
var coffeeFilter = $.filter('**/*.coffee');

gulp.task('scripts', function () {
  return gulp.src([paths.src + '/{app,components}/**/*.coffee', paths.src + '/{app,components}/**/*.js'])
    .pipe($.replace('{{ PUSHER_APP_KEY }}', process.env.PUSHER_APP_KEY))
    .pipe($.replace('{{ HOST_NAME }}', process.env.HOST_NAME))
    .pipe(coffeeFilter)
    .pipe($.coffeelint())
    .pipe($.coffeelint.reporter())
    .pipe($.coffee())
    .pipe(coffeeFilter.restore())
    .on('error', function handleError(err) {
      console.error(err.toString());
      this.emit('end');
    })
    .pipe(gulp.dest(paths.tmp + '/serve/'))
    .pipe($.size())
});

