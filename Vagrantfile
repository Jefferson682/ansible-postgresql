Vagrant.configure("2") do |config|
  config.vm.box = "generic/oracle9"
  config.vm.hostname = "postgres-lab"
  config.vm.network "forwarded_port", guest: 5432, host: 5432
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
  end
end
