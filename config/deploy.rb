# coding: utf-8
set :application, "ruby-hk"
set :repository,  "git@github.com:siuying/ruby-china.git"
set :branch, "ruby-hk"
set :scm, :git

set :user, "siuying"
set :rvm_ruby, "ruby-1.9.2-p290"
set :deploy_to, "/home/#{user}/production/#{application}"

set :deploy_via, :remote_cache
set :git_shallow_clone, 1
set :use_sudo, false

role :web, "202.181.184.27"                          # Your HTTP server, Apache/etc
role :app, "202.181.184.27"                          # This may be the same as your `Web` server
role :db,  "202.181.184.27", :primary => true # This is where Rails migrations will run

# unicorn.rb 路径
set :unicorn_path, "#{deploy_to}/current/config/unicorn.rb"

namespace :deploy do
  task :start, :roles => :app do
    run "cd #{deploy_to}/current/; RAILS_ENV=production unicorn_rails -c #{unicorn_path} -D"
  end

  task :stop, :roles => :app do
    run "kill -QUIT `cat #{deploy_to}/current/tmp/pids/unicorn.pid`"
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "kill -USR2 `cat #{deploy_to}/current/tmp/pids/unicorn.pid`"
  end
end


task :init_shared_path, :roles => :web do
  run "mkdir -p #{deploy_to}/shared/log"
  run "mkdir -p #{deploy_to}/shared/pids"
end

task :link_shared_config_yaml, :roles => :web do
  run "ln -sf #{deploy_to}/shared/config/*.yml #{deploy_to}/current/config/"
  run "ln -sf #{deploy_to}/shared/config/unicorn.rb #{deploy_to}/current/config/"
end

task :restart_resque, :roles => :web do
  run "cd #{deploy_to}/current/; RAILS_ENV=production ./script/resque stop; RAILS_ENV=production ./script/resque start"
end

task :start_mailman, :roles => :web do
  run "cd #{deploy_to}/current/; RAILS_ENV=production ./script/mailman start"
end

task :stopt_mailman, :roles => :web do
  run "cd #{deploy_to}/current/; RAILS_ENV=production ./script/mailman stop"
end

task :restart_mailman, :roles => :web do
  run "cd #{deploy_to}/current/; RAILS_ENV=production ./script/mailman stop; RAILS_ENV=production ./script/mailman start"
end

task :install_gems, :roles => :web do  	
  run "cd #{deploy_to}/current/; bundle install"	  	
end

task :compile_assets, :roles => :web do	  	
  run "cd #{deploy_to}/current/; bundle exec rake assets:precompile"  	
end

task :mongoid_create_indexes, :roles => :web do
  run "cd #{deploy_to}/current/; bundle exec rake db:mongoid:create_indexes"
end

after "deploy:symlink", :init_shared_path, :link_shared_config_yaml, :install_gems, :compile_assets, :mongoid_create_indexes


set :default_environment, {
  'PATH' => "/home/#{user}/.rvm/gems/#{rvm_ruby}/bin:/home/#{user}/.rvm/gems/#{rvm_ruby}@global/bin:/home/#{user}/.rvm/rubies/#{rvm_ruby}/bin:/home/#{user}/.rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games",
  'RUBY_VERSION' => "#{rvm_ruby}",
  'GEM_HOME' => "/home/#{user}/.rvm/gems/#{rvm_ruby}",
  'GEM_PATH' => "/home/#{user}/.rvm/gems/#{rvm_ruby}:/home/#{user}/.rvm/gems/#{rvm_ruby}@global"
}
