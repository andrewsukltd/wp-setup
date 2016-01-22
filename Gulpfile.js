var gulp     = require('gulp'),
sass         = require('gulp-sass'),
autoprefixer = require('gulp-autoprefixer'),
minifycss    = require('gulp-cssnano'),
rename       = require('gulp-rename'),
concat       = require('gulp-concat'),
uglify       = require('gulp-uglify'),
sourcemaps   = require('gulp-sourcemaps'),
pathTheme    = 'siteTheme';


gulp.task('styles', function() {
  return sass('public/wp-content/themes/'+pathTheme+'/scss/', { style: 'expanded' })
    //.pipe(gulp.dest('public/wp-content/themes/'+pathTheme+'/'))
    //.pipe(rename({suffix: '.min'}))
    .pipe(minifycss())
    .pipe(gulp.dest('public/wp-content/themes/'+pathTheme+'/'));
});

gulp.task('watch', function() {
  gulp.watch('public/wp-content/themes/'+pathTheme+'/scss/**/*.scss', ['styles']);
});

gulp.task('scripts', function () {
    return gulp.src(scripts, {base: '.'})
        .pipe(plumber(plumberOptions))
        .pipe(sourcemaps.init({
            loadMaps: false,
            debug: debug,
        }))
        .pipe(gulpif(debug, wrapper({
            header: fileHeader,
        })))
        .pipe(concat('bundle.js', {
            newLine:'\n;' // the newline is needed in case the file ends with a line comment, the semi-colon is needed if the last statement wasn't terminated
        }))
        .pipe(uglify({
            output: { // http://lisperator.net/uglifyjs/codegen
                beautify: debug,
                comments: debug ? true : /^!|\b(copyright|license)\b|@(preserve|license|cc_on)\b/i,
            },
            compress: { // http://lisperator.net/uglifyjs/compress, http://davidwalsh.name/compress-uglify
                sequences: !debug,
                booleans: !debug,
                conditionals: !debug,
                hoist_funs: false,
                hoist_vars: debug,
                warnings: debug,
            },
            mangle: !debug,
            outSourceMap: true,
            //basePath: 'www',
            sourceRoot: '/'
        }))
        .pipe(sourcemaps.write('.', {
            includeContent: true,
            sourceRoot: '/',
        }))
        .pipe(plumber.stop())
        .pipe(gulp.dest('public/wp-content/themes/'+pathTheme+'/js/'))
});

gulp.task('default', ['watch'], function() {

});