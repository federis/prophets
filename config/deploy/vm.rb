set :rails_env, 'production'

set :vm_ip, "10.0.1.22"

role :web, vm_ip
role :app, vm_ip
role :db,  vm_ip, :primary => true