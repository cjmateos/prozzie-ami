actions [:provision]
default_action :provision

action :provision do

  prozzie_dir = '/usr/local/etc/prozzie/ami'
  envs_dir = '/usr/local/etc/prozzie/envs'
  chef_conf_dir = "#{prozzie_dir}/chef_conf"

  [ prozzie_dir, envs_dir, chef_conf_dir ].each do |path|
    directory path do
      owner 'root'
      group 'root'
      mode '0755'
      action :create
    end
  end

  bash 'change owner' do
    user 'root'
    code <<-EOH
    chown -R root:root #{prozzie_dir}
    EOH
  end

  apt_update
  [ 'docker.io' ].each do |pack|
    package pack do
      action :install
    end
  end

  bash 'install docker-compose' do
    user 'root'
    code <<-EOH
    curl -s -L "https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
    chmod +x /usr/bin/docker-compose
    EOH
  end

  cookbook_file "/etc/motd" do
   source 'motd'
   owner 'root'
   group 'root'
   mode '0644'
   action :create
  end

  bash 'remove dinamyc motd' do
    code "rm -f /etc/update-motd.d/*"
    action :run
  end

  chef_gem 'aws-sdk-ec2' do
    action :install
  end

  git "#{prozzie_dir}/prozzie" do
    repository 'https://github.com/wizzie-io/prozzie.git'
    revision node["prozzie_version"]
    action :checkout
  end

  file "#{envs_dir}/base.env" do
    content ''
    owner 'root'
    group 'root'
    mode '0644'
  end

  bash 'pull prozzie images' do
    code <<-EOH
    PREFIX=/usr/local docker-compose -f #{prozzie_dir}/prozzie/compose/base.yaml pull
    rm -f #{envs_dir}/base.env
    EOH
  end

  template '/etc/cloud/cloud.cfg.d/01-wdp.cfg' do
    source 'wdp-cloud-config.cfg.erb'
    owner 'root'
    group 'root'
    mode '0644'
    action :create
  end

  cookbook_file "#{prozzie_dir}/bootstrap.sh" do
    source 'bootstrap.sh'
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end

  cookbook_path = "#{prozzie_dir}/bootstrap-cookbooks"
  template "#{chef_conf_dir}/solo.rb" do
    source 'solo.rb.erb'
    owner 'root'
    group 'root'
    mode '0755'
    variables(:cookbook_path => cookbook_path)
    action :create
  end

  template "#{chef_conf_dir}/node.json" do
    source 'node.json.erb'
    owner 'root'
    group 'root'
    mode '0644'
    action :create
  end
end
