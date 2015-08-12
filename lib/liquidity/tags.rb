module Upstatement

  #
  # Liquid `include` tag, sans-caching
  #
  class Partial < ::Liquid::Include
    private
      def load_cached_partial(context)
        source  = read_template_from_file_system(context)
        partial = ::Liquid::Template.parse(source, pass_options)
        partial
      end
  end

  #
  # Middleman `LoremObject` exposure for Liquid.
  #
  class Lorem < ::Liquid::Tag
    include Upstatement::Common

    def initialize(tag_name, markup, options)
      super
      @args = markup.strip.chomp.split(' ')
      @meth = @args.shift.strip
      if @meth == 'image'
        size = chomp_quotes(@args.shift)
        opts = @args.inject({}) do |result, element|
          kv = element.split(':')
          if kv.length == 2
            result[ kv.first.to_sym ] = chomp_quotes(kv.last)
          end
          result
        end
        @args = [size, opts]
      else
        @args.map! do |arg|
          begin
            arg.to_i
          rescue
            arg
          end
        end
      end
    end

    def render(context)
      ::Upstatement::Middleman.app.lorem.send( @meth.to_sym, *@args )
    end
  end

  #
  # Middleman/Padrino `page_classes` tag promoted to Liquid.
  #
  class PageClasses < ::Liquid::Tag
    def initialize(tag_name, markup, options)
      super
      @args = markup.strip.chomp.split(' ')
    end

    def render(context)
      ::Upstatement::Middleman.app.page_classes( *@args )
    end
  end

  #
  # Middleman/Padrino `javascript_include_tag` tag.
  #
  class JavascriptIncludeTag < ::Liquid::Tag
    include Upstatement::Common

    def initialize(tag_name, markup, options)
      super
      @args = markup.strip.chomp.split(' ').map { |arg| chomp_quotes(arg) }
    end

    def render(context)
      # Allow custom script types via colon delimiter: eg, 'a_javascript_file:text/ups'
      @args.map do |arg|
        arg_parts = arg.split(':')
        if arg_parts.length == 1
          arg_parts.push 'text/javascript'
        end
        ::Upstatement::Middleman.app.javascript_include_tag(
          arg_parts.first, { 'type': arg_parts.last }
          )
      end.join('')
    end
  end

  #
  # Middleman/Padrino `stylesheet_link_tag` tag.
  #
  class StylesheetLinkTag < ::Liquid::Tag
    include Upstatement::Common

    def initialize(tag_name, markup, options)
      super
      @args = markup.strip.chomp.split(' ').map { |arg| chomp_quotes(arg) }
    end

    def render(context)
      @args.map do |arg|
        ::Upstatement::Middleman.app.stylesheet_link_tag( arg )
      end.join('')
    end
  end

end

Liquid::Template.register_tag('stylesheet_link_tag', Upstatement::StylesheetLinkTag)
Liquid::Template.register_tag('javascript_include_tag', Upstatement::JavascriptIncludeTag)
Liquid::Template.register_tag('page_classes', Upstatement::PageClasses)
Liquid::Template.register_tag('partial', Upstatement::Partial)
Liquid::Template.register_tag('lorem', Upstatement::Lorem)
