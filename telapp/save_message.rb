class SaveMessage 

  def self.process
    require 'rubygems'
    require 'aws/s3'
    gem 'twitter'
    require 'twitter'
    require 'beanstalk-client'
    require 'yaml'

    config_file = "config/config.yml"

    config = YAML.load(File.read(config_file))
    
    
    AWS::S3::Base.establish_connection!(
    :access_key_id     => config['AWS_ACCESS_KEY_ID'],
    :secret_access_key => config['AWS_SECRET_ACCESS_KEY']
    )
    
    require 'rubygems'
    require 'beanstalk-client'
    beanstalk = Beanstalk::Pool.new(['127.0.0.1:11300'])
    message = beanstalk.reserve
    
    infilename = message.ybody.first + ".wav"
    outfilename = message.ybody.first + ".mp3"
    system "lame -SV9 #{infilename} #{outfilename}"
    AWS::S3::S3Object.store("#{message.ybody.last.to_s}.mp3", open(outfilename), config['AWS_S3_BUCKET'], :access => :public_read)
    awsbucket = AWS::S3::Bucket.find(config['AWS_S3_BUCKET'])
    url = awsbucket["#{message.ybody.last.to_s}.mp3"].url :authenticated => false

    httpauth = Twitter::HTTPAuth.new(config['TWITTER_ACCOUNT'], config['TWITTER_PASSWORD'])
    client = Twitter::Base.new(httpauth)
    client.update(url)
    message.delete
  end
  
end