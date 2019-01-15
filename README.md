# Jekyll::AssetPipeline

This gem is an external asset pipeline for Jekyll projects. It supports [Sass](https://sass-lang.com/) for CSS, and ES6 for JavaScript (via [Babel](https://babeljs.io/)). It also runs [PurgeCSS](https://www.purgecss.com/) to remove unnecessary CSS and [Uglify](https://github.com/mishoo/UglifyJS2) to compress JavaScript.

Installation
----------

Add this line to your application's `Gemfile`:

```rb
gem 'jekyll-asset-pipeline', git: 'https://github.com/crdschurch/jekyll-asset-pipeline', tag: '0.0.1'
```

And then execute:

    $ bundle exec jekyll-asset-pipeline install

This script does the following:

- Installs `purgecss` globally via NPM.
- Installs local JS package dependencies, which will create a `package.json` file if it doesn't already exit.
- Copies `gulpfile.js` into the project root. This is the configuration for the build process, which you're welcome to customize as necessary.
- Copies `purgecss.config.json` into the project root. This is the configuration for PurgeCSS, which you are also welcome to customize as necessary.

The process will also likely create a `package-lock.json` file and a `node_modules` directory. It is recommended that you add the `node_modules` directory to your `.gitignore` file.

Introduction
----------

The build process has three primary components:

1. [Gulp.js](https://gulpjs.com/): The build process. The build logic and configuration can be found in `gulpfile.js`, which is copied into the root of your project during installation.
2. A series of Jekyll hooks that control when (and whether or not) to run the asset build when the jekyll build is run.
3. Jekyll tags to support resolving the appropriate filename for your `<link>` and `<script>` tags.

Usage
----------

The build is run via Gulp.js (which is run via an NPM script). This occurs automatically as part of the Jekyll build process (`jekyll build` or `jekyll serve`).

The build uses `_assets/stylesheets` as the source directory for (S)CSS files and `_assets/javascripts` as the source for JS files. (More on each of these in their respective sections, below.)

The build will run if any of the following conditions are true:

- `BUILD_ASSETS` environment variable is set to `true` (i.e. `BUILD_ASSETS=true jekyll [build/serve]`).
- The hash file (used to reference the last used hash) does not exist. (More on this below.)
- There are no `.js` or `.css` files in the build directory.
- A `.js` or `.scss` file within the source directory has been modified since the last time the build was run.

### Liquid/HTML Tags

Within a Jekyll view (HTML file), you can use the custom tags to load the appropriate file(s):

```liquid
{% javascript_link_tag application %}
{% stylesheet_link_tag application %}
```

_Notice the lack of file extension._

The `javascript_link_tag` accepts a second argument for which you can add an `async` or `defer` attribute to the script tag.

### Configuration

Aside from the environment variable mentioned above, you have the option to adjust one value in your site's `_config.yml` file.

- `asset_dest` (default: `assets`): The directory within your build directory in which to house the built assets.

CSS
----------

The CSS builds one sass source file (`_assets/stylesheets/application.scss`) and puts the compiled output in `_site/assets/`. There is nothing to configure, as Sass supports importing partials by default.

JavaScript
----------

JavaScript is more configurable that the CSS. All JS build configuration can be found in `_assets/javascripts/config.js`. This file is to export an array of config objects, where each object represents a built file with the following options:

- `name` (Required): The name of the file (sans `.js` extension).
- `deps`: An array of vendors files (dependencies, sans `.js` extension) to prepend to the built file.
- `files`: An array of files (sans `.js` extension) to process with Babel and then append to the built file.

The resulting file(s) will be placed in `_site/assets/`.

Take the following example:

```js
module.exports = [
  {
    name: 'application',
    deps: [
      'vendor/jquery.min',
      'vendor/lodash.min'
    ],
    files: [
      'components/header'
    ]
  }
]
```

Given the config above, `_assets/javascripts/vendor/jquery.min.js` (notice `.js` extension is automatically added) and `_assets/javascripts/vendor/lodash.min.js` will be prepended to a temporary file, while `_assets/javascripts/components/header.js` will be processed with Babel (to support older browsers), minified, and appended to the same file. This file will eventually become named `application.js` (because of the `name` option in the config) and will be placed in `_site/assets/`.

The Cache Hash
----------

This build process supports appending a cache hash to the end of each file. This will happen automatically if you let the Jekyll hooks build the project. This hash will also be used with the Jekyll tags so that your view files load the appropriate files.

If you are building via the command line, you can set the `ASSET_HASH` environment variable to add a hash.

Troubleshooting
----------

If you start the Jekyll server and there are missing styles or your scripts are working, it's likely that the Jekyll asset tags are looking for a different filename than what exists in your build directory (`_site`, by default). There are two quick options to fix:

1. Delete the build directory and restart the server (or re-run the build).
2. Save a file in your assets source directory. The next time the project builds (which would be instantaneously if the server is already running) the assets will regenerate.

Contributing
----------

Bug reports and pull requests are welcome on GitHub at https://github.com/crdschurch/jekyll-asset-pipeline. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

Code of Conduct
----------

Everyone interacting in the Jekyll::Asset::Pipeline project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/crdschurch/jekyll-asset-pipeline/blob/master/CODE_OF_CONDUCT.md).
