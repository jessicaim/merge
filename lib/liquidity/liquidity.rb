require 'liquid'
require 'lib/ext/common'

require_relative 'drops'
require_relative 'filters'
require_relative 'tags'

module Upstatement

  # Adding an app scope to Middleman for reference by Liquidty tags and filters.
  #
  # Assign in config.rb via:
  # ready do
  #   Upstatement::Middleman.app = self
  # end
  #
  module Middleman
    class << self
      attr_accessor :app
    end
  end

  module Renderers
    module Liquidity
      class << self

        def registered(app)
          app.before_configuration do
            template_extensions liquid: :html
          end

          # After config, setup liquid partial paths
          app.after_configuration do
            ::Liquid::Template.file_system = ::Liquid::LocalFileSystem.new(source_dir)

            # Proxy stuff to Liquid
            sitemap.provides_metadata %r{\.liquid$} do
              {
                locals: {
                  sitemap:      ::Upstatement::Liquid::SitemapDrop.new( sitemap ),
                  data:         ::Upstatement::Liquid::DataDrop.new( data ),
                  current_page: Proc.new {
                    ::Upstatement::Liquid::ResourceDrop.new( current_page )
                  }
                }
              }
            end
          end
        end
        #
        alias_method :included, :registered

      end # self
    end # Liquidity
  end # Renderers

  class Liquidity < ::Middleman::Extension
    option :debug, false, 'Print debug information'

    def initialize(app, options_hash={}, &block)
      super
      if options.debug == true
        puts '** Registering Upstatement "Liquidity" Renderer'
      end
      app.register Renderers::Liquidity
    end
  end

end # Upstatement

# Register Liquidity in default Liquid renderer's place
::Middleman::Extensions.register( :liquid, Upstatement::Liquidity )
