require 'json'
require 'colorize'

namespace :assets do
  task :precompile do
    sh 'middleman build'
  end
end

namespace :up do
  namespace :deploy do
    task :create, [ :name ] do |t, args|
      args.with_defaults(:name => '')
      if args[:name].empty?
        sh 'heroku create'
      else
        sh "heroku create #{args[:name]}"
      end
    end

    task :push, [ :branch ] do |t, args|
      args.with_defaults(:branch => '')
      if args[:branch].empty?
        sh "git push heroku master"
      else
        sh "git push heroku #{args[:branch]}:master"
      end
    end

    task :show do
      sh 'heroku open'
    end

    task :rename, [ :name ] do |t, args|
      args.with_defaults(:name => '')
      if args[:name].empty?
        puts "`rake up:deploy:rename['my_new_name']`"
      else
        sh "heroku apps:rename #{args[:name]}"
        Rake::Task["up:deploy:show"].invoke
      end
    end
  end

  @deploy_config_path = File.join( File.dirname( __FILE__ ), '.deploy' )

  task :statement do
    deploy_config = {
      name:   '',
      branch: 'master'
    }
    create_config = true

    puts "* Looking for existing deployment configuration"
      .white.on_black
    if File.exist?( @deploy_config_path )
      begin
        deploy_config.merge!(
          JSON.parse( File.read('.deploy') ).inject({}) { |r, (k, v)|
            r[k.to_sym] = v
            r
          })
      rescue
        create_config = true
      end
    end

    if create_config
      puts "* Creating new deployment configuration..."
        .white.on_black

      begin
        project = File.dirname( __FILE__ ).split('/').last
        puts "* Step 1 of 3:\n\tWhat is the name of your project? Leave blank for `#{project}`:"
          .yellow.on_black
        input   = STDIN.gets.strip.chomp
        name    = "uppe-#{input.empty? ? project : input}"
      end until !name.empty?

      begin
        puts "* Step 2 of 3:\n\tIf you would like to deploy a specific git branch, enter the branch name now. Leave blank for `master`:"
          .yellow.on_black
        input   = STDIN.gets.strip.chomp
        branch  = input.empty? ? 'master' : input
      end until !branch.empty?

      begin
        puts "* Step 3 of 3:\n\tPlease confirm, branch '#{branch}' will be deployed to '#{name}.herokuapp.com'\n\tIs this correct? (y/n)"
          .yellow.on_black
        input   = STDIN.gets.strip.chomp
        answer  = input.empty? ? 'n' : input[0].downcase
      end until %w{y n}.include?(input)

      if input == 'y'
        deploy_config.merge!({ name: name, branch: branch })

        File.open( @deploy_config_path, 'w' ) do |f|
          f.write deploy_config.to_json
        end

        puts "* Deployment configuration added."
      else
        puts "* Deployment canceled. Goodbye!"
          .red.on_black
        next
      end

      Rake::Task["up:deploy:show"].invoke
    end

    # if create_config
    #   Rake::Task["up:deploy:show"].invoke

    puts deploy_config.inspect

  end

end

# https://devcenter.heroku.com/articles/git
# https://devcenter.heroku.com/articles/using-the-cli

# Existing heroku deployment?
# git remote add heroku https://git.heroku.com/app-name.git

# To list apps
# heroku apps

# To remove an app
# heroku apps:destroy -a app-name --confirm app-name

# To change remotes, etc:
# git remote rm origin
# git remote rm heroku
# git remote -v
# git remote add origin <URL to new heroku app>
