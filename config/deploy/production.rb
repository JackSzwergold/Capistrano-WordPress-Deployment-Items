# branch: Set the github branch that will be used for this deployment.
# server: The name of the destination server you will be deploying to.
# web_builds: The directory on the server into which the actual source code will deployed.
# live_root: The live directory which the current version will be linked to.
# live_dir: The actual directly which will be linked to the current web build.

set :branch, "master"

server "www.preworn.com", :app, :web, :db, :primary => true
set :web_builds, "#{web_root}/builds"
set :config_cache, "#{deployment_root}/configs/#{application}"
set :content_data_path, "#{deployment_root}/content/#{application}"
set :live_root,   "#{web_root}/www.preworn.com/site/tests"
set :live_dir, "#{application}"

set :deploy_to, "#{web_builds}/#{application}"

# Remote caching will keep a local git repository on the server you're deploying to and
# simply run a fetch from that rather than an entire clone. This is probably the best
# option as it will only fetch the changes since the last deploy.
set :deploy_via, :remote_cache

# Disable warnings about the absence of the styleseheets, javscripts & images directories.
set :normalize_asset_timestamps, false

before "deploy:create_symlink" do
  # Link the main '.htaccess' configuration file.
  run "cd #{current_release} && ln -sf #{config_cache}/htaccess.txt ./.htaccess"
  # Link the main 'wp-config.php' configuration file.
  run "cd #{current_release} && ln -sf #{config_cache}/wp-config.php ./wp-config.php"
end

after "deploy:create_symlink" do
  # Link "current" into the web root
  run "cd #{live_root} && ln -s #{current_path} #{live_dir}"
end

after "deploy:update", "deploy:cleanup"