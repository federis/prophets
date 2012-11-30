set :rails_env, 'production'

set :vm_ip, "192.168.5.153"

role :web, vm_ip
role :app, vm_ip
role :db,  vm_ip, :primary => true