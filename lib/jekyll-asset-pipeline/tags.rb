module Jekyll
  module AssetPipeline
    class Tag < Liquid::Tag
      include LiquidExtensions

      def initialize(tag_name, input, tokens)
        super
        @input = input.split(' ').map(&:strip).compact
      end

      private

      def site
        @site ||= Jekyll.sites.first
      end

      def file_path(context, ext)
        filename = lookup_variable(context, @input.first).strip
        "/#{site.config['asset_dest']}/#{filename}-#{site.config['asset_hash']}.#{ext}"
      end
    end

    class StylesheetLinkTag < Tag
      def render(context)
        "<link href=\"#{file_path(context, 'css')}\" rel=\"stylesheet\">"
      end
    end

    class JavascriptLinkTag < Tag
      def render(context)
        "<script async type=\"text/javascript\" src=\"#{file_path(context, 'js')}\" #{@input[1]}></script>"
      end
    end
  end
end

Liquid::Template.register_tag('stylesheet_link_tag', Jekyll::AssetPipeline::StylesheetLinkTag)
Liquid::Template.register_tag('javascript_link_tag', Jekyll::AssetPipeline::JavascriptLinkTag)
