#!/usr/bin/env puma

environment "production"
daemonize true

workers 0
threads 0, 16

wd = File.expand_path('../../', __FILE__)
tmp_path = File.join(wd, 'log')
Dir.mkdir(tmp_path) unless File.exist?(tmp_path)

bind  "unix:///var/run/topfun.sock"
pidfile File.join(tmp_path, 'puma.pid')
state_path File.join(tmp_path, 'puma.state')
stdout_redirect File.join(tmp_path, 'puma.out.log'), File.join(tmp_path, 'puma.err.log'), true

preload_app! #utilizing copy-on-write
activate_control_app
on_worker_boot do
  # worker specific setup
  ActiveRecord::Base.connection_pool.disconnect!
  ActiveSupport.on_load(:active_record) do
    config = ActiveRecord::Base.configurations[Rails.env] ||
      Rails.application.config.database_configuration[Rails.env]
    config['reaping_frequency'] = ENV['DB_REAP_FREQ'] || 10
    config['pool'] = ENV['MAX_THREADS'] || 16
    ActiveRecord::Base.establish_connection(config)
  end
end

