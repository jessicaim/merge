module Upstatement

  module LinkFilters
    #
    # link_to
    #
    def link_to( str, *args )
      "<a href=#{args.first}>#{str}</a>"
    end
  end

  module StringFilters
    #
    # titlelize
    #
    def titlelize( str )
      str.gsub(/\b('?[a-z])/) { $1.capitalize }
    end

    #
    # truncate
    #
    def truncate( str, *args )
      ::Upstatement::Middleman.app.truncate( str, length: args.first + 3 )
    end

    #
    # truncate_words
    #
    def truncate_words( str, *args )
      ::Upstatement::Middleman.app.truncate_words( str, length: args.first )
    end

    #
    # slugify
    #
    def slugify( str, *args )
      unless str.empty?
        str.downcase.dasherize.parameterize
      else
        ''
      end
    end
  end

  module CollectionFilters
    #
    # fetch - Supports dynamic keying on data collections.
    #
    # <ul>
    # {% for i in (1..3) %}
    #   <li>{{ data.articles | fetch: i | first }}
    # {% endfor %}
    # </ul>
    #
    def fetch( collection, *args )
      result = ''

      if collection.is_a?(Hash)
        result = collection.with_indifferent_access["#{args.first}"]
      elsif collection.is_a?(Array)
        result = collection[ Integer(args.first) ]
      else
        begin
          result = JSON.parse( collection.to_s.gsub('=>', ':') )["#{args.first}"]
        rescue JSON::ParserError => e
          puts e.inspect and return ''
        end
      end

      result
    end
  end

end

Liquid::Template.register_filter(Upstatement::LinkFilters)
Liquid::Template.register_filter(Upstatement::StringFilters)
Liquid::Template.register_filter(Upstatement::CollectionFilters)
