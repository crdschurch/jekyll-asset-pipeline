require 'fileutils'
require 'active_support/all'

require 'jekyll-asset-pipeline/extensions/string_colorize'

module Jekyll
  module AssetPipeline
    class Installer

      # This class is called via the command-line script in
      # exe/jekyll-asset-pipeline. The first arugment after the command must match
      # the name of the class method it is to run.
      #
      #     $ bundle exec jekyll-asset-pipeline install
      #
      # Currently, the only supported method is `install` (alias: `i`). If any other
      # method is called the `method_missing` will throw an error.
      #
      class << self
        def install
          Jekyll::AssetPipeline::Installer.new.install
        end

        alias_method :i, :install

        def method_missing(method_name, *args, &block)
          msg = "ERROR: Command `#{method_name}` does not exist."
          Jekyll::AssetPipeline::Installer.new.send(:output, msg, :red)
        end
      end

      # Install is the main installation process. It requires that npm be installed
      # and will fail if it can't find the npm command. Otherwise, it goes through
      # the installation process.
      #
      def install
        return install_npm_error if `which npm`.blank?
        init_package_json
        install_npm_packages
        add_build_script
        copy_gulp_config
        copy_purgecss_config
        output('--- Done! jekyll-asset-pipeline install successfully! ---', :green)
      end

      private

      # ---------------------------------------- | References

      # package.json file in the Jekyll project.
      def package_json_file
        @package_json_file ||= "#{FileUtils.pwd}/package.json"
      end

      # ---------------------------------------- | Helpers

      # Log output to the terminal.
      def output(msg, color_code = nil)
        msg = msg.colorize(color_code) if color_code
        puts(msg)
      end

      # Log the command to be run, then run the command.
      def system(cmd)
        output("> #{cmd}", :cyan)
        super(cmd)
      end

      # Copy a template from src (this project) to dest (Jekyll project).
      def template(src, dest)
        FileUtils.cp(src, dest, preserve: true)
      end

      # ---------------------------------------- | Actions

      # Output error message when npm is not installed.
      def install_npm_error
        output('ERROR: You must install npm prior to installing the asset pipeline.', :red)
      end

      # Add a blank package.json file if it doesn't exist
      def init_package_json
        File.open(package_json_file, 'w+') { |f| f.write('{}') } unless File.exists?(package_json_file)
      end

      # Install all necessary global and local JS dependencies.
      def install_npm_packages
        system("npm install --global purgecss")
        system("npm install --save-dev @babel/core @babel/preset-env crds-styles del gulp@4.0.0 gulp-babel gulp-concat gulp-plumber gulp-rename gulp-sass gulp-uglify node-sass-tilde-importer")
      end

      # Add build script to package.json file and write to file.
      def add_build_script
        config = JSON.parse(File.read(package_json_file))
        (config['scripts'] ||= {})['build'] = 'gulp'
        File.open(package_json_file, 'w+') { |f| f.write(JSON.pretty_generate(config)) }
      end

      # Copy gulpfile.js into the root of the project.
      def copy_gulp_config
        template(File.expand_path('../templates/gulpfile.js', __dir__), "#{FileUtils.pwd}/gulpfile.js")
      end

      # Copy purgecss.config.json into the root of the project.
      def copy_purgecss_config
        template(File.expand_path('../templates/purgecss.config.json', __dir__), "#{FileUtils.pwd}/purgecss.config.json")
      end

    end
  end
end
