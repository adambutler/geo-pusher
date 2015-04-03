'use strict';

var gulp = require('gulp');

var paths = gulp.paths;

var $ = require('gulp-load-plugins')();

var haml = require('gulp-haml');

gulp.task('markups', function() {
  function renameToHtml(path) {
    path.extname = '.html';
  }

  return gulp.src(paths.src + '/{app,components}/**/*.haml')
    .pipe(haml({ext: '.html'}))
    .on('error', function handleError(err) {
      console.error(err.toString());
      this.emit('end');
    })
    .pipe(gulp.dest(paths.tmp + '/serve/'));
});
