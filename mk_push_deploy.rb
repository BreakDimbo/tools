#!/Users/break/.rvm/rubies/ruby-2.4.2/bin/ruby

# usage ./mk_push_deploy.rb -s[service] -t[target] -c[local:docker] -d[work_directory]
# example ruby mk_push_deploy.rb -s tower,msg_pusher -t udesk.test.dcc,udesk.cti.sipp -c docker -d /Users/break/Work/Workspace/udesk/udesk_qilin_cti

require 'optparse'

DefaultDir = "/Users/break/Work/Workspace/udesk/udesk_qilin_cti"
DefaultCompile = :docker

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ./mk_push_deploy.rb -s[service] -t[target] -c[local:docker] -d[work_directory]"

  opts.on("-s", "--services [services]", Array, "make services") do |v|
    options[:services] = v
  end

  opts.on("-t", "--targets [Target]", Array, "target servers") do |v|
    options[:targets] = v
  end

  opts.on("-c", "--compile [Compile way]", [:local, :docker], "select compile way from local or docker") do |v|
    options[:compile] = v
  end

  opts.on("-d", "--dir [Dir]", String, "directory dir") do |v|
    options[:dir] = v
  end
end.parse!

p options

def make_in_docker(services)
  services.each do |service|
    puts "start make #{service} ..."
    raise unless system("make build_#{service}_in_docker")
    puts "over make #{service} ..."
  end
end

def make_local(services)
  services.each do |service|
    puts "start make #{service} ..."
    raise unless system("make #{service}")
    puts "over make #{service} ..."
  end
end

def push(services, target, dir)
  services.each do |service|
    puts "start push #{service} to #{target}"
    raise unless system("ssh #{target} \"sudo systemctl stop udesk_#{service}\"")
    raise unless system("scp #{dir}/bin/udesk_#{service} #{target}:/usr/local/kylin_cti/current/bin")
    puts "over push #{service} to #{target}"
  end
end

def restart(services, target)
  services.each do |service|
    puts "restart #{service} on #{target}"
    raise unless system("ssh #{target} \"sudo systemctl start udesk_#{service}\"")
    puts "#{service} started"
  end
end

def check
  # TODO 检查版本
end

def start(options)
  work_dir = options[:dir] || DefaultDir
  compile_way = options[:compile] || DefaultCompile
  services = options[:services]
  targets = options[:targets]
  Dir.chdir(work_dir)
  
  case compile_way
  when :local
    make_local(services)
  when :docker
    make_in_docker(services)
  end
  
  targets.each do |target|
    push(services,target,work_dir)
    restart(services,target)
    check()
  end
end

start(options)