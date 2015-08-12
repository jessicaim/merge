module Upstatement
  module Liquid
    class SitemapDrop < ::Liquid::Drop
      def initialize( sitemap )
        @sitemap = sitemap
      end

      def resources
        cache_resources
      end

      def to_s
        {
          resources: self.resources.inject([]) { |result, el|
            el.to_liquid
          }
        }
      end

      private

      def cache_resources
        @resources ||= @sitemap.resources.collect { |resource|
          ResourceDrop.new( resource )
        }
      end
    end

    class ResourceDrop < ::Liquid::Drop
      def initialize( resource )
        @resource = resource
      end

      def url
        @resource.url
      end

      def data
        @resource.data.to_h
      end

      def to_s
        { url: self.url, data: self.data }
      end
    end

    class DataDrop < ::Liquid::Drop
      def initialize( data )
        @hash = data.to_h
        @data = Upstatement::Common.h2o( data )
      end

      def before_method( method )
        @data.send( method )
      end

      def to_s
        @hash.inspect
      end
    end
  end
end
