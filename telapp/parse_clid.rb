class ParseCLID
  def self.parse(number)
    if number =~ /^\+44/
      case number
      when /^\+44(1\d1).*/ then "0#{$1}"
      when /^\+44(2\d).*/ then "0#{$1}"
      when /^\+44(1\d\d\d).*/ then "0#{$1}"
      when /^\+447.*/ then "someone's mobile phone"
      end
    else
      "a strange and mysterious place"
    end
  end
end