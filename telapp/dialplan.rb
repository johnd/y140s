adhearsion {
  def record_message
    play "#{SOUNDS_DIR}/record"
    @filename = "/tmp/" + uniqueid.to_s
    record @filename + ".wav", :silence => 5, :maxduration => 140
    save_menu
  end
  
  def save_menu
    menu "#{SOUNDS_DIR}/verification",
    :timeout => 8.seconds, :tries => 3 do |link|
      link.on_save 1
      link.on_retry 2
    end
  end
  
  play "#{SOUNDS_DIR}/intro"
  record_message
}

def on_save
  require 'rubygems'
  require 'delayed_job'
  require 'save_message.rb'
  Delayed::Job.enqueue(SaveMessage.new(@filename,uniqueid))
  play "#{SOUNDS_DIR}/posting"
  play "#{SOUNDS_DIR}/outro"
  
  hangup
end

def on_retry
  record_message
end