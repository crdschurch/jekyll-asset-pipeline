require 'fileutils'
require 'active_support/all'

require 'jekyll-asset-pipeline/extensions/string_colorize'

class Jekyll::AssetPipeline::Installer

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

  def install
    return install_npm_error if `which npm`.blank?
    init_package_json
    install_npm_packages
    add_build_script
    copy_build_file
    output('--- Done! jekyll-asset-pipeline install successfully! ---', :green)
  end

  private

  def output(msg, color_code = nil)
    msg = msg.colorize(color_code) if color_code
    puts(msg)
  end

  def system(cmd)
    output("> #{cmd}", :cyan)
    super(cmd)
  end

  def install_npm_error
    output('ERROR: You must install npm prior to installing the asset pipeline.', :red)
  end

  def init_package_json
    File.open(package_json_file, 'w+') { |f| f.write('{}') } unless File.exists?(package_json_file)
  end

  def install_npm_packages
    system("npm install --global purgecss")
    system("npm install --save-dev @babel/core @babel/preset-env crds-styles del gulp gulp-babel gulp-concat gulp-plumber gulp-rename gulp-sass gulp-uglify node-sass-tilde-importer")
  end

  def add_build_script
    config = JSON.parse(File.read(package_json_file))
    (config['scripts'] ||= {})['build'] = 'gulp'
    File.open(package_json_file, 'w+') { |f| f.write(config.to_json) }
  end

  def copy_build_file
    template(File.expand_path('../templates/gulpfile.js', __dir__), "#{FileUtils.pwd}/gulpfile.js")
  end

  def package_json_file
    @package_json_file ||= "#{FileUtils.pwd}/package.json"
  end

  def template(src, dest)
    FileUtils.cp(src, dest)
  end

end
