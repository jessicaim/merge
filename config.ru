require 'rubygems'
require 'middleman/rack'

@auth = IO.readlines(".htaccess")

use Rack::Auth::Basic, "Restricted Area" do |u, p|
  result = false
  @auth.each do |line|
    auth_pair = line.chomp.split(',')
    result = ( auth_pair & [ u, p ] == auth_pair )
    break if ( result === true )
  end
  result
end

# run Middleman.server

use Rack::TryStatic, root: 'build', urls: %w[/], try: ['.html', 'index.html', '/index.html']

run lambda { |env|
  not_found_page = File.expand_path("../build/404.html", __FILE__)
  if File.exist?(not_found_page)
    [ 404, { 'Content-Type'  => 'text/html'}, [File.read(not_found_page)] ]
  else
    [ 404, { 'Content-Type'  => 'text/html' }, ['404 - page not found'] ]
  end
}
