class SaveMessage 

  def self.process
    require 'rubygems'
    require 'aws/s3'
    gem 'twitter'
    require 'twitter'
    require 'beanstalk-client'
    require 'yaml'
    require 'parse_clid.rb'

    config_file = "#{File.dirname(__FILE__)}/config/config.yml"

    config = YAML.load(File.read(config_file))
    
    
    AWS::S3::Base.establish_connection!(
    :access_key_id     => config['AWS_ACCESS_KEY_ID'],
    :secret_access_key => config['AWS_SECRET_ACCESS_KEY']
    )
    
    require 'rubygems'
    require 'beanstalk-client'
    beanstalk = Beanstalk::Pool.new(['127.0.0.1:11300'])
    message = beanstalk.reserve(10)
    
    infilename = "/tmp/" + message.ybody.first + ".wav"
    outfilename = "/tmp/" + message.ybody.first + ".mp3"
    system "lame -SV9 #{infilename} #{outfilename}"
    filename = message.ybody.first.hash.abs.to_s(36)
    AWS::S3::S3Object.store("#{filename}.mp3", open(outfilename), config['AWS_S3_BUCKET'], :access => :public_read)
    url = "http://#{config['URL_DOMAIN']}/#{filename}.mp3"
    clid = message.ybody.last

    httpauth = Twitter::HTTPAuth.new(config['TWITTER_ACCOUNT'], config['TWITTER_PASSWORD'])
    client = Twitter::Base.new(httpauth)
    client.update("A message from #{ParseCLID.parse(clid)}: #{url}")
    message.delete
  end
  
end