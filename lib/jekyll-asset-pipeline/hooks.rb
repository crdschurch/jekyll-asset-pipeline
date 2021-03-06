require 'securerandom'
require 'fileutils'

module Jekyll
  module AssetPipeline
    class Hooks

      attr_accessor :site

      def initialize(site)
        self.site = site
      end

      # Sets default site config values:
      #
      #   asset_dest: The directory (within _site) in which to drop built assets.
      #
      #   keep_files: Ensures that we don't delete assets that have already been
      #               built, so we can persist asset builds between Jekyll builds.
      #
      def init_config
        config('asset_dest', 'assets')
        config('keep_files', []).push(config('asset_dest'))
      end

      # If we're ready to build (see `run_build?` below), use "build_assets" on
      # the site as the means for determining what to build.
      #
      def init_build
        if run_build?
          config('build_assets', true, true)
        else
          config('build_assets', false, true)
        end
      end

      # If "build_assets" is set, then we are ready to do a build. Delete all the
      # existing build files, then run the build.
      #
      def run_build
        return unless config('build_assets')
        %w{js css}.each { |ext| FileUtils.rm(Dir.glob("#{build_dir}/*.#{ext}")) }
        system("npm run build")
        File.open(cache_file, 'w+') { |f| f.write('') }
      end

      private

        def config(key, value = nil, force = false)
          return site.config[key] ||= value if value.nil? || !force
          site.config[key] = value
        end

        # Run the build if any of the following are true:
        #
        #   - BUILD_ASSETS env var is set to true.
        #   - There are no .js or .css files in the build directory.
        #   - Any source asset has been manipulated since the cache file was
        #     written.
        #
        def run_build?
          ENV['BUILD_ASSETS'].to_s == 'true' ||
            build_files.blank? ||
            src_files.select { |f| File.mtime(f) >= File.mtime(cache_file) }.any?
        end

        def development?
          (ENV['JEKYLL_ENV'] ||= 'development') == 'development'
        end

        def cache_file
          @cache_file ||= begin
            FileUtils.mkdir('tmp') unless Dir.exists?('tmp')
            'tmp/.asset_cache'
          end
        end

        def build_dir
          @build_dir ||= "#{config('destination')}/#{config('asset_dest')}"
        end

        def build_files
          @build_files ||= Dir.glob("#{build_dir}/**/*").select { |f| f.ends_with?('.css') || f.ends_with?('.js') }
        end

        def src_dir
          @src_dir ||= '_assets'
        end

        def src_files
          @src_files ||= Dir.glob("#{src_dir}/**/*").select { |f| f.ends_with?('.scss') || f.ends_with?('.js') }
        end

    end
  end
end

Jekyll::Hooks.register(:site, :after_init) do |site|
  Jekyll::AssetPipeline::Hooks.new(site).init_config
end

Jekyll::Hooks.register(:site, :pre_render) do |site|
  Jekyll::AssetPipeline::Hooks.new(site).init_build
end

Jekyll::Hooks.register(:site, :post_write) do |site|
  Jekyll::AssetPipeline::Hooks.new(site).run_build
end
