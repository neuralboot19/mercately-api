# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
# Don't declare `role :all`, it's a meta role
# role :app, %w{deploy@104.131.36.116}
# role :web, %w{deploy@104.131.36.116}
# role :db,  %w{deploy@104.131.36.116}

# set :branch, 'master'
set :branch, 'master'
set :rails_env, 'production'
# Extended Server Syntax
# ======================
role :web, %w{10.116.0.5 10.116.0.4 10.116.0.7 10.116.0.6 10.116.0.10 10.116.0.9 10.116.0.11}, user: 'mercately'
role :app, %w{10.116.0.5 10.116.0.4 10.116.0.7 10.116.0.6 10.116.0.10 10.116.0.9 10.116.0.11}, user: 'mercately'
role :db, %w{10.116.0.5}, user: 'mercately'

# This can be used to drop a more detailed server
# definition into the server list. The second argument
# something that quacks like a hash can be used to set
# extended properties on the server.
# server '104.131.36.116', user: 'deploy', roles: %w{web app}, my_property: :my_value

# you can set custom ssh options
# it's possible to pass any option but you need to keep in mind that net/ssh understand limited list of options
# you can see them in [net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start)
# set it globally
#  set :ssh_options, {
#    keys: %w(/home/user/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(publickey)
#  }
# and/or per server
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
# setting per server overrides global ssh_options

