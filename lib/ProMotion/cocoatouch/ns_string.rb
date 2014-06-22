class NSString
  def to_url
    NSURL.URLWithString(self)
  end
end
