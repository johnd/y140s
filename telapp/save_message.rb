class SaveMessage < Struct.new(:filename, :uniqueid)
  def perform
    require 'rubygems'
    require 'aws/s3'
    AWS::S3::Base.establish_connection!(
    :access_key_id     => AWS_ACCESS_KEY_ID,
    :secret_access_key => AWS_SECRET_ACCESS_KEY
    )
    infilename = filename + ".wav"
    outfilename = filename + ".mp3"
    system "lame -SV9 #{infilename} #{outfilename}"
    AWS::S3::S3Object.store("#{uniqueid.to_s}.mp3", open(outfilename), AWS_S3_BUCKET, :access => :public_read)
    awsbucket = AWS::S3::Bucket.find(AWS_BUCKET)
    url = awsbucket["#{uniqueid}.mp3"].url :authenticated => false
    if user_id
      user = User.find(user_id)
    end
    if user
      rant = user.rants.new(:file_url=>url)
    else 
      rant = Rant.new(:file_url => url)
    end
    rant.save
  end
end