class OldSha1
  def self.encrypt(*tokens)
    password, salt = tokens
    digest = Digest::SHA1.hexdigest("--#{salt}--#{password}--")
    digest
  end
  
  def self.matches?(crypted, *tokens)
    encrypt(*tokens) == crypted
  end
end