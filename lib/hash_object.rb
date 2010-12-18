class HashObject < Hash

  module ExtendMethodsSymbol
    def method_missing(sym,*args)
      return self[$1.to_sym] = args[0] if args.size==1 && /^(.*)=$/===sym.to_s
      return super(sym,*args) if args.size>0
      self[sym]
    end    
  end

  module ExtendMethodsString
    def method_missing(sym,*args)
      return self[$1] = args[0] if args.size==1 && /^(.*)=$/===sym.to_s
      return super(sym,*args) if args.size>0
      self[sym.to_s]
    end    
  end
  
  def initialize(keytype=:Symbol,hash=nil,deep=true)
    merge!(hash) if hash
    self.class.extend_hash(keytype,self,deep)
  end
  
  def self.extend_value(keytype,v,deep=true)
    case v
      when Hash: extend_hash(keytype,v,deep)
      when Array: extend_array(keytype,v,deep)
    end
  end
  
  def self.extend_hash(keytype,hash,deep=true)    
    hash.extend(keytype_module(keytype))
    hash.each { |k,v| extend_value(keytype,v,deep) } if deep
    hash
  end
  
  def self.extend_array(keytype,array,deep=true)
    array.each { |v| extend_value(keytype,v,deep) }
  end

  private
  
  @@keytype_module = { :Symbol => ExtendMethodsSymbol, :String => ExtendMethodsString }  
  def self.keytype_module(keytype)
    @@keytype_module[keytype] || raise("Unknown key type (#{keytype})")
  end
  
end