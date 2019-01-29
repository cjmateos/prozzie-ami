include ProzzieBootstrap::Helper

actions :config
default_action :config

action :config do

  prozzie_dir = '/usr/local/etc/prozzie/ami'
  wizzie_home = '/home/wizzie'
  user_data_file = '/var/lib/cloud/instance/user-data.txt'

  user_data = {}
  begin
    user_data = YAML.load_file(user_data_file)
    user_data = {} unless user_data
  rescue => e
    Chef::Log.error("Cannot read user-data: #{e.message}")
  end

  template "#{prozzie_dir}/firstboot.sh" do
    source 'firstboot.sh.erb'
    owner 'root'
    group 'root'
    mode '0755'
    variables(:wizzie_home => wizzie_home,
              :prozzie_dir => prozzie_dir)
    action :create
  end

  template "#{prozzie_dir}/prozzie.conf" do
    source 'prozzie.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(:public_ip => public_ip,
              :api_key => user_data["api_key"],
              :http_endpoint => user_data["http_endpoint"])
    action :create
  end

  bash 'create wizzie user' do
   code <<-EOH
   adduser wizzie --home #{wizzie_home} --shell /bin/bash --gecos "" --disabled-password
   echo "wizzie ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/95-wizzie-users
   cp -r /home/ubuntu/.ssh #{wizzie_home} && chown -R wizzie #{wizzie_home}/.ssh
   sed -i 's/\\(.*\\)ubuntu\\(.*\\)/\\1wizzie\\2/g' /root/.ssh/authorized_keys
   echo "bash #{prozzie_dir}/firstboot.sh" >> #{wizzie_home}/.bashrc
   EOH
  end

  bash 'install prozzie' do
    code <<-EOH
    source #{prozzie_dir}/prozzie.conf
    if [ "x$HTTP_ENDPOINT" != "x" -a "x$HTTP_POST_PARAMS" != "xapikey:" ]; then
      env $(cat #{prozzie_dir}/prozzie.conf) #{prozzie_dir}/prozzie/setups/linux_setup.sh
      [ "x$?" == "x0" ] && date > #{wizzie_home}/.installed
    else
      echo "Prozzie cannot be automatically configured. It must be configured at first boot"
    fi
    EOH
  end

end
