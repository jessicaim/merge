###
# Custom Liquid integration
###

require 'lib/liquidity/liquidity'

ready do
  Upstatement::Middleman.app = self
end

activate :liquid do |config|
  config.debug = true
end

# Setup a /menu proxy to index.html
proxy "/menu", "/index.html"

# Parse .bowerrc for Bower/Sprockets config
@bowerrc = JSON.parse( IO.read("#{root}/.bowerrc") )

###
# Compass
###

# Change Compass configuration
compass_config do |config|
  config.output_style = :compact
end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
# page "/path/to/file.html", :layout => false
#
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
#
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy pages (https://middlemanapp.com/advanced/dynamic_pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", :locals => {
#  :which_fake_page => "Rendering a fake page with a local variable" }

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

###
# Configuration
###

activate :deploy do |deploy|
  deploy.method           = :git
  deploy.build_before     = true

  # Optional Settings
  # deploy.remote         = 'custom-remote'   # remote name or git url, default: origin
  # deploy.branch         = 'custom-branch'   # default: gh-pages
  # deploy.strategy       = :submodule        # commit strategy: can be :force_push or :submodule, default: :force_push
  # deploy.commit_message = 'custom-message'  # commit message (can be empty), default: Automated commit at `timestamp` by middleman-deploy `version`
end

# Autoprefix activation & config
activate :autoprefixer do |config|
#   config.browsers = ['last 2 versions', 'Explorer >= 9']
#   config.cascade  = false
#   config.inline   = true
#   config.ignore   = ['hacks.css']
end

configure :development do
  # Do NOT concatenate in development
  set :debug_assets, false

  # Reload the browser automatically whenever files change
  activate :livereload
end

after_configuration do
  sprockets.append_path File.join root, @bowerrc["directory"]

  # Import each dependency defined in bower.json relative to Bower dir
  JSON.parse( File.read('bower.json') )['dependencies'].each do |k, v|
    sprockets.import_asset k if v ==~ /(git)/
  end
end

after_build do |builder|
  # Move .htaccess into place within build directory
  %w{ .htaccess }.each do |f|
    builder.source_paths << File.dirname(__FILE__)
    builder.copy_file(
      File.join(root, f), File.join(config[:build_dir], f)
      )
  end
end

set :css_dir,     'static/scss'
set :js_dir,      'static/js'
set :images_dir,  'static/img'
set :fonts_dir,   'static/fonts'

set :relative_links, true

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Concatenate assets for build
  set :debug_assets, false

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  activate :asset_hash

  # Use relative URLs
  activate :relative_assets

  # Sourcemaps!
  set :sass, :sourcemap => :inline

  # Or use a different image path
  # set :http_prefix, "/Content/images/"

  # Build pages as directories with indexes:
  # eg, about-us.html.liquid => /about-us ( instead of about-us.html )
  # activate :directory_indexes
end
