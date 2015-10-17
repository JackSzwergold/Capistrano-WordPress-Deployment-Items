require 'capistrano/ext/multistage'
set :stages, ['sandbox', 'production']
set :default_stage, 'sandbox'
set :application, "wordpresstest"
set :repository, "git@github.com:JackSzwergold/WordPressTest.git"
set :git_enable_submodules, true

set :scm, :git
set :use_sudo, false
set :keep_releases, 3
ssh_options[:forward_agent] = true

set :web_root, "/var/www"
set :deployment_root, "#{web_root}"

namespace :deploy do
  task :restart do
    #nothing
  end
  task :create_release_dir, :except => {:no_release => true} do
    run "mkdir -p #{fetch :releases_path}"
  end
end

# Link the 'uploads' folder into the current 'wp-content' directory; removes whatever 'uploads' exist in the repo.
task :link_content do
  run "cd #{current_release}/wp-content && if [ -d uploads ]; then rm -rf uploads; fi && ln -s #{content_data_path}/uploads ./uploads"
end

# Clean up the stray symlinks: current, log, public & tmp
task :delete_extra_symlink do
  # Get rid of Ruby related symlinks
  run "cd #{current_path} && if [ -h current ]; then rm current; fi && if [ -h log ]; then rm log; fi"
  # Get rid of Ruby specific symlinks & parent folders.
  run "cd #{current_path} && if [ -d public ]; then rm -rf public; fi && if [ -d tmp ]; then rm -rf tmp; fi"
end

# Delete capistrano 'Capfile' & related config files & 'read me' from release
task :delete_cap_files do
  run "cd #{current_release} && rm Capfile && rm -rf config && if [ -f README.md ]; then rm README.md; fi"
end

# Echo the current path to a file.
task :echo_current_path do
  run "echo #{current_release} > #{current_release}/CURRENT_PATH"
end

before "deploy:update", "deploy:create_release_dir"
before "deploy:create_symlink", :delete_cap_files
after "deploy:create_symlink", :link_content
after "deploy:update", :delete_extra_symlink
after "deploy:update", :echo_current_path