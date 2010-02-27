adhearsion {
  def record_message
    play "#{SOUNDS_DIR}/record"
    @filename = "/tmp/" + uniqueid.to_s
    record @filename + ".wav", :silence => 5, :maxduration => 140
    save_menu
  end
  
  def save_menu
    menu "#{SOUNDS_DIR}/verification1",@filename,"#{SOUNDS_DIR}/verification2",
      :timeout => 8.seconds, :tries => 3 do |link|
        link.on_retry 2
        link.on_save 1

        link.on_invalid { play 'invalid' }

        link.on_premature_timeout do |str|
          play 'sorry'
        end

        link.on_failure do
          play 'goodbye'
          hangup
        end
      end
    end
  sleep 1 # Otherwise it'll cut off the start of the first audio file played.
  play "#{SOUNDS_DIR}/intro"
  record_message
}

on_save do
  require 'rubygems'
  require 'beanstalk-client'
  beanstalk = Beanstalk::Pool.new(['127.0.0.1:11300'])
  beanstalk.yput([@filename,uniqueid])
  play "#{SOUNDS_DIR}/posting"  
  play "#{SOUNDS_DIR}/outro"
  
  hangup
end

on_retry do
  record_message
end