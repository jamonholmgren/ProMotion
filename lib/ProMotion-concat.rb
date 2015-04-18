# =====================================================================
# /Users/jh/.gem/ruby/2.2.0/gems/motion-stump-0.3.2/lib/stump/metaid.rb
# =====================================================================
# thanks _why
# http://whytheluckystiff.net/articles/seeingMetaclassesClearly.html
class Object
  # The hidden singleton lurks behind everyone
  def metaclass; class << self; self; end; end
  def meta_eval &blk; metaclass.instance_eval &blk; end

  # Adds methods to a metaclass
  def meta_def name, &blk
    meta_eval {
      define_method(name) {|*args, &block|
        blk.call(*args, &block)
      }
    }
  end

  # Defines an instance method within a class
  def class_def name, &blk
    class_eval { define_method name, &blk }
  end
end
# ========================================================================
# /Users/jh/.gem/ruby/2.2.0/gems/motion-stump-0.3.2/lib/stump/metareset.rb
# ========================================================================
class Object
  def safe_meta_def method_name, &method_body
    metaclass.remember_original_method(method_name)
    meta_eval {
      define_method(method_name) {|*args, &block|
        method_body.call(*args, &block)
      }
    }
  end

  def reset(method_name)
    metaclass.restore_original_method(method_name)
  end

  protected

  def remember_original_method(method_name)
    alias_method "__original_#{method_name}".to_sym, method_name if method_defined?(method_name)
    self
  end

  def restore_original_method(method_name)
    original_method_name = "__original_#{method_name}".to_sym
    if method_defined?(original_method_name)
      alias_method method_name, original_method_name
      remove_method original_method_name
    end
    self
  end
end
# ===================================================================
# /Users/jh/.gem/ruby/2.2.0/gems/motion-stump-0.3.2/lib/stump/mock.rb
# ===================================================================
class Object
  # Create a mock method on an object.  A mock object will place an expectation
  # on behavior and cause a test failure if it's not fulfilled.
  #
  # ==== Examples
  #
  #    my_string = "a wooden rabbit"
  #    my_string.mock!(:retreat!, :return => "run away!  run away!")
  #    my_string.mock!(:question, :return => "what is the airspeed velocity of an unladen sparrow?")
  #
  #    # test/your_test.rb
  #    my_string.retreat!    # => "run away!  run away!"
  #    # If we let the test case end at this point, it fails with:
  #    # Unmet expectation: #<Sparrow:1ee7> expected question
  #
  def mock!(method, options = {}, &block)
    Stump::Mocks.add([self, method])

    behavior =  if block_given?
                  lambda do |*args|
                    raise ArgumentError if block.arity >= 0 && args.length != block.arity

                    Stump::Mocks.verify([self, method])
                    block.call(*args)
                  end
                elsif !options[:yield].nil?
                  lambda do |*args|
                    Stump::Mocks.verify([self, method])
                    yield(options[:yield])
                  end
                else
                  lambda do |*args|
                    Stump::Mocks.verify([self, method])
                    return options[:return]
                  end
                end

    safe_meta_def method, &behavior
  end

  def should_not_call(method)
    behavior =  lambda do |*args|
                  should.flunk "Umet expectations: #{method} expected to not be called"
                end
    safe_meta_def method, &behavior
  end
end

module Kernel
  # Create a pure mock object rather than mocking specific methods on an object.
  #
  # ==== Examples
  #
  #     my_mock = mock(:thing, :return => "whee!")
  #     my_mock.thing    # => "whee"
  #
  def mock(method, options = {}, &block)
    mock_object = Object.new
    mock_object.mock!(method, options, &block)
    mock_object
  end
end


# ====================================================================
# /Users/jh/.gem/ruby/2.2.0/gems/motion-stump-0.3.2/lib/stump/mocks.rb
# ====================================================================
module Stump
  # A class to track the mocks and proxies that have been satisfied
  class Mocks
    class <<self
      def size
        @mocks ? 0 : @mocks.size 
      end

      def add(mock)
        @mocks ||= []
        Bacon::Counter[:requirements] += 1
        @mocks << mock
      end
      
      def verify(mock)
        @mocks.delete(mock)
      end
      
      def failures
        @mocks
      end
      
      def clear!
        @mocks = []
      end
    end
  end
end
# ====================================================================
# /Users/jh/.gem/ruby/2.2.0/gems/motion-stump-0.3.2/lib/stump/proxy.rb
# ====================================================================
class Object
  # Creates a proxy method on an object.  In this setup, it places an expectation on an object (like a mock)
  # but still calls the original method.  So if you want to make sure the method is called and still return
  # its value, or simply want to invoke the side effects of a method and return a stubbed value, then you can
  # do that.
  #
  # ==== Examples
  #
  #     class Parrot
  #       def speak!
  #         puts @words
  #       end
  #
  #       def say_this(words)
  #         @words = words
  #         "I shall say #{words}!"
  #       end
  #     end
  #
  #     # => test/your_test.rb
  #     sqawky = Parrot.new
  #     sqawky.proxy!(:say_this)
  #     # Proxy method still calls original method...
  #     sqawky.say_this("hey")   # => "I shall say hey!"
  #     sqawky.speak!            # => "hey"
  #
  #     sqawky.proxy!(:say_this, "herro!")
  #     # Even though we return a stubbed value...
  #     sqawky.say_this("these words")   # => "herro!"
  #     # ...the side effects are still there.
  #     sqawky.speak!                    # => "these words"
  #
  # TODO: This implementation is still very rough.  Needs refactoring and refining.  Won't 
  # work on ActiveRecord attributes, for example.
  #
  def proxy!(method, options = {}, &block)
    Stump::Mocks.add([self, method])
    
    if respond_to?(method)
      proxy_existing_method(method, options, &block)
    else
      proxy_missing_method(method, options, &block)
    end
  end
  
  protected
  def proxy_existing_method(method, options = {}, &block)
    method_alias = "__old_#{method}".to_sym
    
    meta_eval do
      module_eval do
        alias_method method_alias, method
      end
    end
    
    check_arity = Proc.new do |args|
      arity = method(method_alias.to_sym).arity
      if ((arity >= 0) ?
          (args.length != arity) :
          (args.length < ~arity))
        # Negative arity means some params are optional, so we check
        # for the minimum required.  Sadly, we can't tell what the
        # maximum is.
        raise ArgumentError
      end
    end
    
    behavior = if options[:return]
                  lambda do |*args| 
                    check_arity.call(args)
                    
                    Stump::Mocks.verify([self, method])

                    if method(method_alias.to_sym).arity == 0
                      send(method_alias)
                    else
                      send(method_alias, *args)
                    end

                    return options[:return]
                  end
                else
                  lambda do |*args| 
                    check_arity.call(args)

                    Stump::Mocks.verify([self, method])
                    
                    if method(method_alias.to_sym).arity == 0
                      return send(method_alias)
                    else
                      return send(method_alias, *args)
                    end
                  end
                end

    meta_def method, &behavior
  end
  
  def proxy_missing_method(method, options = {}, &block)
    behavior = if options[:return]
                  lambda do |*args|
                    Stump::Mocks.verify([self, method])
                    
                    method_missing(method, args)
                    return options[:return]
                  end
                else
                  lambda do |*args|
                    Stump::Mocks.verify([self, method])
      
                    method_missing(method, args)
                  end
                end
    
    meta_def method, &behavior
  end
end

# ===================================================================
# /Users/jh/.gem/ruby/2.2.0/gems/motion-stump-0.3.2/lib/stump/stub.rb
# ===================================================================
class Object
  # Create a stub method on an object.  Simply returns a value for a method call on
  # an object.
  #
  # ==== Examples
  #
  #    my_string = "a wooden rabbit"
  #    my_string.stub!(:retreat!, :return => "run away!  run away!")
  #
  #    # test/your_test.rb
  #    my_string.retreat!    # => "run away!  run away!"
  #
  def stub!(method_name, options = {}, &stubbed)
    behavior = (block_given? ? stubbed : lambda { return options[:return] })

    safe_meta_def method_name, &behavior
  end
end

module Kernel
  # Create a pure stub object.
  #
  # ==== Examples
  #
  #     stubbalicious = stub(:failure, "wat u say?")
  #     stubbalicious.failure     # => "wat u say?"
  #
  def stub(method, options = {}, &block)
    stub_object = Object.new
    stub_object.stub!(method, options, &block)

    stub_object
  end
end
# ======================================================================
# /Users/jh/.gem/ruby/2.2.0/gems/motion-stump-0.3.2/lib/stump/version.rb
# ======================================================================
module Stump
  VERSION = "0.3.2"
end

# ===============================================================
# /Users/jh/.gem/ruby/2.2.0/gems/webstub-1.1.2/lib/webstub/api.rb
# ===============================================================
module WebStub
  module API
    extend self

    def disable_network_access!
      protocol.disable_network_access!
    end

    def enable_network_access!
      protocol.enable_network_access!
    end

    def stub_request(method, path)
      protocol.add_stub(method, path)
    end

    def reset_stubs
      protocol.reset_stubs
    end

    private

    def protocol
      Dispatch.once { NSURLProtocol.registerClass(WebStub::Protocol) }

      Protocol
    end
  end
end

# ====================================================================
# /Users/jh/.gem/ruby/2.2.0/gems/webstub-1.1.2/lib/webstub/protocol.rb
# ====================================================================
module WebStub
  class Protocol < NSURLProtocol
    def self.add_stub(*args)
      registry.add_stub(*args)
    end

    def self.canInitWithRequest(request)
      return false unless spec_mode?
      return false unless supported?(request)

      if stub_for(request)
        return true
      end

      ! network_access_allowed?
    end

    def self.canonicalRequestForRequest(request)
      request
    end

    def self.disable_network_access!
      @network_access = false
    end

    def self.enable_network_access!
      @network_access = true
    end

    def self.network_access_allowed?
      @network_access.nil? ? true : @network_access
    end

    def self.reset_stubs
      registry.reset
    end

    def initWithRequest(request, cachedResponse:response, client: client)
      if super
        @stub = nil
        @timer = nil
      end

      self
    end

    def completeLoading
      response = NSHTTPURLResponse.alloc.initWithURL(request.URL,
                                                     statusCode:@stub.response_status_code,
                                                     HTTPVersion:"HTTP/1.1",
                                                     headerFields:@stub.response_headers)
      @stub.requests += 1

      if @stub.error?
        client.URLProtocol(self, didFailWithError: @stub.response_error)
        return
      end

      if @stub.redirects?
        url = NSURL.URLWithString(@stub.response_headers["Location"])
        redirect_request = NSURLRequest.requestWithURL(url)

        client.URLProtocol(self, wasRedirectedToRequest: redirect_request, redirectResponse: response)

        unless @stub = self.class.stub_for(redirect_request)
          error = NSError.errorWithDomain("WebStub", code:0, userInfo:{ NSLocalizedDescriptionKey: "network access is not permitted!"})
          client.URLProtocol(self, didFailWithError:error)

          return
        end

        @timer = NSTimer.scheduledTimerWithTimeInterval(@stub.response_delay, target:self, selector: :completeLoading, userInfo:nil, repeats:false)
        return
      end

      client.URLProtocol(self, didReceiveResponse:response, cacheStoragePolicy:NSURLCacheStorageNotAllowed)
      client.URLProtocol(self, didLoadData: @stub.response_body.is_a?(NSData) ? @stub.response_body :
                         @stub.response_body.dataUsingEncoding(NSUTF8StringEncoding))
      client.URLProtocolDidFinishLoading(self)
    end

    def startLoading
      request = self.request
      client = self.client
    
      unless @stub = self.class.stub_for(self.request)
        error = NSError.errorWithDomain("WebStub", code:0, userInfo:{ NSLocalizedDescriptionKey: "network access is not permitted!"})
        client.URLProtocol(self, didFailWithError:error)

        return
      end

      if body = self.class.parse_body(request)
        @stub.do_callback(self.request.allHTTPHeaderFields, body)
      end
      @timer = NSTimer.scheduledTimerWithTimeInterval(@stub.response_delay, target:self, selector: :completeLoading, userInfo:nil, repeats:false)
    end

    def stopLoading
      if @timer
        @timer.invalidate
      end
    end

  private

    def self.registry
      @registry ||= Registry.new()
    end

    def self.stub_for(request)
      options = { headers: request.allHTTPHeaderFields }
      if body = parse_body(request)
        options[:body] = body
      end

      registry.stub_matching(request.HTTPMethod, request.URL.absoluteString, options)
    end

    def self.parse_body(request)
      return nil unless request.HTTPBody

      content_type = nil

      request.allHTTPHeaderFields.each do |key, value|
        if key.downcase == "content-type"
          content_type = value
          break
        end
      end

      body = NSString.alloc.initWithData(request.HTTPBody, encoding:NSUTF8StringEncoding)
      return nil unless body

      case content_type
      when /application\/x-www-form-urlencoded/
        URI.decode_www_form(body)
      else
        body
      end
    end

    def self.spec_mode?
      RUBYMOTION_ENV == 'test'
    end

    def self.supported?(request)
      return false unless request.URL
      return false unless request.URL.scheme.start_with?("http")

      true
    end
  end
end

# =======================================================================================
# /Users/jh/.gem/ruby/2.2.0/gems/webstub-1.1.2/lib/webstub/patch/session_configuration.rb
# =======================================================================================
if Kernel.const_defined?(:NSURLSessionConfiguration)
  class NSURLSessionConfiguration
    class << self
      alias_method :originalDefaultSessionConfiguration, :defaultSessionConfiguration

      def defaultSessionConfiguration
        config = originalDefaultSessionConfiguration

        protocols = (config.protocolClasses && config.protocolClasses.clone) || []
        unless protocols.include?(WebStub::Protocol)
          protocols.unshift WebStub::Protocol
          config.protocolClasses = protocols
        end

        config
      end

      alias_method :originalEphemeralSessionConfiguration, :ephemeralSessionConfiguration

      def ephemeralSessionConfiguration
        config = originalEphemeralSessionConfiguration

        protocols = (config.protocolClasses && config.protocolClasses.clone) || []
        unless protocols.include?(WebStub::Protocol)
          protocols.unshift WebStub::Protocol
          config.protocolClasses = protocols
        end

        config
      end
    end
  end
end

# ================================================================
# /Users/jh/.gem/ruby/2.2.0/gems/webstub-1.1.2/lib/webstub/json.rb
# ================================================================
module WebStub
  module JSON
    def self.generate(hash)
      error = Pointer.new(:object)
      result = NSJSONSerialization.dataWithJSONObject(hash, options:0, error:error)

      NSString.alloc.initWithData(result, encoding:NSUTF8StringEncoding)
    end

    def self.parse(str)
      data = str
      unless data.is_a?(NSData)
        data = str.dataUsingEncoding(NSUTF8StringEncoding)
      end

      error = Pointer.new(:object)
      result = NSJSONSerialization.JSONObjectWithData(data, options: 0, error: error)

      result
    end
  end
end

# ====================================================================
# /Users/jh/.gem/ruby/2.2.0/gems/webstub-1.1.2/lib/webstub/registry.rb
# ====================================================================
module WebStub
  class Registry
    def initialize()
      @stubs = []
    end

    def add_stub(method, path)
      stub = Stub.new(method, path)
      @stubs << stub

      stub
    end

    def reset
      @stubs = []
    end

    def size
      @stubs.size
    end
    
    def stub_matching(method, url, options={})
      @stubs.each do |stub|
        if stub.matches?(method, url, options)
          return stub
        end
      end

      nil
    end
  end
end

# ================================================================
# /Users/jh/.gem/ruby/2.2.0/gems/webstub-1.1.2/lib/webstub/stub.rb
# ================================================================
module WebStub
  class Stub
    METHODS = ["GET", "POST", "PUT", "DELETE", "HEAD", "OPTIONS", "PATCH"].freeze

    def initialize(method, url)
      @request_method = canonicalize_method(method)
      raise ArgumentError, "invalid method name" unless METHODS.include? @request_method

      @requests = 0

      @request_url = canonicalize_url(url)
      @request_headers = nil
      @request_body = nil
      @callback = nil

      @response_body = ""
      @response_delay = 0.0
      @response_error = nil
      @response_headers = {}
      @response_status_code = 200
    end

    def error?
      ! @response_error.nil?
    end

    def matches?(method, url, options={})
      if @request_url != canonicalize_url(url)
        return false
      end

      if @request_method != canonicalize_method(method)
        return false
      end

      if @request_headers
        headers = options[:headers] || {}

        @request_headers.each do |key, value|
          if headers[key] != value
            return false
          end
        end
      end

      if @request_body
        if @request_body != options[:body]
          return false
        end
      end

      true
    end

    attr_accessor :requests
    attr_accessor :callback

    def redirects?
      @response_status_code.between?(300, 399) && @response_headers["Location"] != nil
    end

    def requested?
      @requests > 0
    end

    attr_reader :response_body
    attr_reader :response_delay
    attr_reader :response_error
    attr_reader :response_headers
    attr_reader :response_status_code

    def to_fail(options)
      if error = options.delete(:error)
        @response_error = error
      elsif code = options.delete(:code)
        @response_error = NSError.errorWithDomain(NSURLErrorDomain, code: code, userInfo: nil)
      else
        raise ArgumentError, "to_fail requires either the code or error option"
      end

      self
    end

    def to_return(options)
      if status_code = options[:status_code]
        @response_status_code = status_code
      end

      if headers = options[:headers]
        @response_headers.merge!(headers)
      end

      if json = options[:json]
        @response_body = json
        @response_headers["Content-Type"] = "application/json"

        if @response_body.is_a?(Hash) || @response_body.is_a?(Array)
          @response_body = JSON.generate(@response_body)
        end
      else
        @response_body = options[:body] || ""

        if content_type = options[:content_type]
          @response_headers["Content-Type"] = content_type
        end
      end

      if delay = options[:delay]
        @response_delay = delay
      end

      self
    end

    def do_callback(headers, body)
      if @callback
        @callback.call(headers, body)
      end
    end

    def with_callback(&callback)
      @callback = callback
    end

    def to_redirect(options)
      unless url = options.delete(:url)
        raise ArgumentError, "to_redirect requires the :url option"
      end

      options[:headers] ||= {}
      options[:headers]["Location"] = url
      options[:status_code] = 301

      to_return(options)
    end

    def with(options)
      if body = options[:body]
        @request_body = body

        if @request_body.is_a?(Hash)
          @request_body = @request_body.inject({}) { |h, (k,v)| h[k.to_s] = v; h }
        end
      end

      if headers = options[:headers]
        @request_headers = headers
      end

      self
    end

  private

    def canonicalize_method(method)
      method.to_s.upcase
    end

    def canonicalize_url(url)
      scheme, authority, hostname, port, path, query, fragment = URI.split(url)

      parts = scheme.downcase
      parts << "://"

      if authority
        parts << authority
        parts << "@"
      end

      parts << hostname.downcase

      if port
        well_known_ports = { "http" => 80, "https" => 443 }
        if well_known_ports[scheme] != port
          parts << ":#{port}"
        end
      end

      if path != "/"
        parts << path
      end

      if query && !query.empty?
        parts << "?#{query}"
      end

      if fragment && !fragment.empty?
        parts << "##{fragment}"
      end

      parts
    end
  end
end

# ========================================================================
# /Users/jh/.gem/ruby/2.2.0/gems/webstub-1.1.2/lib/webstub/spec_helpers.rb
# ========================================================================
module WebStub
  module SpecHelpers
    def self.extended(base)
      base.class.send(:include, WebStub::API)

      base.after { reset_stubs }
    end
  end
end

# ===================================================================
# /Users/jh/.gem/ruby/2.2.0/gems/webstub-1.1.2/lib/webstub/version.rb
# ===================================================================
module WebStub
  VERSION = "1.1.2"
end

# ===============================================================
# /Users/jh/.gem/ruby/2.2.0/gems/webstub-1.1.2/lib/webstub/uri.rb
# ===============================================================
module WebStub
  module URI
    def self.decode_www_form(str)
      str.split("&").inject({}) do |hash, component|
        key, value = component.split("=", 2)
        hash[decode_www_form_component(key)] = decode_www_form_component(value)

        hash
      end
    end

    def self.decode_www_form_component(str)
      str.gsub("+", " ").stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    end

    def self.split(str)
      url = NSURL.URLWithString(str)

      scheme = url.scheme
      user = url.user
      password = url.password
      hostname = url.host
      port = url.port
      path = url.path
      query = url.query
      fragment = url.fragment

      user_info = nil
      if user || password
        user_info = "#{user}:#{password}"
      end

      [scheme, user_info, hostname, port, path, query, fragment]
    end
  end
end

# =====================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/version.rb
# =====================================================
module ProMotion
  VERSION = "2.3.0" unless defined?(ProMotion::VERSION)
end

# ==============================================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/cocoatouch/navigation_controller.rb
# ==============================================================================
module ProMotion
  class NavigationController < UINavigationController

    def popViewControllerAnimated(animated)
      super
      self.viewControllers.last.send(:on_back) if self.viewControllers.last.respond_to?(:on_back)
    end

    def shouldAutorotate
      visibleViewController.shouldAutorotate if visibleViewController
    end

    def supportedInterfaceOrientations
      visibleViewController.supportedInterfaceOrientations
    end

    def preferredInterfaceOrientationForPresentation
      visibleViewController.preferredInterfaceOrientationForPresentation
    end

  end
end

# ==============================================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/cocoatouch/split_view_controller.rb
# ==============================================================================
module ProMotion
  class SplitViewController < UISplitViewController
    def master_screen
      s = self.viewControllers.first
      s.respond_to?(:visibleViewController) ? s.visibleViewController : s
    end

    def detail_screen
      s = self.viewControllers.last
      s.respond_to?(:visibleViewController) ? s.visibleViewController : s
    end

    def master_screen=(s)
      self.viewControllers = [ (s.navigationController || s), self.viewControllers.last]
    end

    def detail_screen=(s)
      # set the button from the old detail screen to the new one
      button = detail_screen.navigationItem.leftBarButtonItem
      s.navigationItem.leftBarButtonItem = button

      self.viewControllers = [self.viewControllers.first, (s.navigationController || s)]
    end

    def screens=(s_array)
      self.viewControllers = s_array
    end
  end
end

# ==================================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/cocoatouch/ns_string.rb
# ==================================================================
class NSString
  def to_url
    NSURL.URLWithString(self)
  end
end

# ===============================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/cocoatouch/ns_url.rb
# ===============================================================
class NSURL
  def to_url
    self
  end
end

# =============================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/styling/styling.rb
# =============================================================
module ProMotion
  module Styling
    def set_attributes(element, args = {})
      args = get_attributes_from_symbol(args)
      ignore_keys = [:transition_style, :presentation_style]
      args.each do |k, v|
        set_attribute(element, k, v) unless ignore_keys.include?(k)
      end
      element.send(:on_styled) if element.respond_to?(:on_styled)
      element
    end

    def set_attribute(element, k, v)
      return unless element

      if !element.is_a?(CALayer) && v.is_a?(Hash) && element.respond_to?("#{k}=")
        element.send("#{k}=", v)
      elsif v.is_a?(Hash) && element.respond_to?(k)
        sub_element = element.send(k)
        set_attributes(sub_element, v) if sub_element
      elsif element.respond_to?("#{k}=")
        element.send("#{k}=", v)
      elsif v.is_a?(Array) && element.respond_to?("#{k}") && element.method("#{k}").arity == v.length
        element.send("#{k}", *v)
      elsif k.to_s.include?("_") # Snake case?
        set_attribute(element, camelize(k), v)
      else # Warn
        PM.logger.debug "set_attribute: #{element.inspect} does not respond to #{k}=."
        PM.logger.log("BACKTRACE", caller(0).join("\n"), :default) if PM.logger.level == :verbose
      end
      element
    end

    def content_max(view, mode = :height)
      view.subviews.map do |sub_view|
        if sub_view.isHidden
          0
        elsif mode == :height
          sub_view.frame.origin.y + sub_view.frame.size.height
        else
          sub_view.frame.origin.x + sub_view.frame.size.width
        end
      end.max.to_f
    end

    def content_height(view)
      content_max(view, :height)
    end

    def content_width(view)
      content_max(view, :width)
    end

    # iterate up the view hierarchy to find the parent element
    # of "type" containing this view
    def closest_parent(type, this_view = nil)
      this_view ||= view_or_self.superview
      while this_view != nil do
        return this_view if this_view.is_a? type
        this_view = this_view.superview
      end
      nil
    end

    def add(element, attrs = {})
      add_to view_or_self, element, attrs
    end

    def remove(elements)
      Array(elements).each(&:removeFromSuperview)
    end

    def add_to(parent_element, elements, attrs = {})
      attrs = get_attributes_from_symbol(attrs)
      Array(elements).each do |element|
        parent_element.addSubview element
        set_attributes(element, attrs) if attrs && attrs.length > 0
        element.send(:on_load) if element.respond_to?(:on_load)
      end
      elements
    end

    def view_or_self
      self.respond_to?(:view) ? self.view : self
    end

    # These three color methods are stolen from BubbleWrap.
    def rgb_color(r,g,b)
      rgba_color(r,g,b,1)
    end

    def rgba_color(r,g,b,a)
      r,g,b = [r,g,b].map { |i| i / 255.0}
      UIColor.colorWithRed(r, green: g, blue:b, alpha:a)
    end

    def hex_color(str)
      hex_color = str.gsub("#", "")
      case hex_color.size
      when 3
        colors = hex_color.scan(%r{[0-9A-Fa-f]}).map{ |el| (el * 2).to_i(16) }
      when 6
        colors = hex_color.scan(%r<[0-9A-Fa-f]{2}>).map{ |el| el.to_i(16) }
      else
        raise ArgumentError
      end

      raise ArgumentError unless colors.size == 3
      rgb_color(colors[0], colors[1], colors[2])
    end

    # Turns a snake_case string into a camelCase string.
    def camelize(str)
      str.split('_').inject([]){ |buffer,e| buffer.push(buffer.empty? ? e : e.capitalize) }.join
    end

  protected

    def get_attributes_from_symbol(attrs)
      return attrs if attrs.is_a?(Hash)
      PM.logger.error "#{attrs} styling method is not defined" unless self.respond_to?(attrs)
      new_attrs = send(attrs)
      PM.logger.error "#{attrs} should return a hash" unless new_attrs.is_a?(Hash)
      new_attrs
    end

    def map_resize_symbol(symbol)
      @_resize_symbols ||= {
        left:     UIViewAutoresizingFlexibleLeftMargin,
        right:    UIViewAutoresizingFlexibleRightMargin,
        top:      UIViewAutoresizingFlexibleTopMargin,
        bottom:   UIViewAutoresizingFlexibleBottomMargin,
        width:    UIViewAutoresizingFlexibleWidth,
        height:   UIViewAutoresizingFlexibleHeight
      }
      @_resize_symbols[symbol] || symbol
    end

  end
end

# ===============================================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/table/cell/table_view_cell_module.rb
# ===============================================================================
module ProMotion
  module TableViewCellModule
    include Styling

    attr_accessor :data_cell, :table_screen

    def setup(data_cell, screen)
      self.table_screen = WeakRef.new(screen)
      self.data_cell = data_cell

      check_deprecated_styles
      set_styles
      set_title
      set_subtitle
      set_image
      set_remote_image
      set_accessory_view
      set_selection_style
      set_accessory_type
    end

  protected

    # TODO: Remove this in ProMotion 2.1. Just for migration purposes.
    def check_deprecated_styles
      whitelist = [ :title, :subtitle, :image, :remote_image, :accessory, :selection_style, :action, :long_press_action, :arguments, :cell_style, :cell_class, :cell_identifier, :editing_style, :moveable, :search_text, :keep_selection, :height, :accessory_type, :style, :properties ]
      if (data_cell.keys - whitelist).length > 0
        PM.logger.deprecated("In #{self.table_screen.class.to_s}#table_data, you should set :#{(data_cell.keys - whitelist).join(", :")} in a `properties:` hash. See TableScreen documentation.")
      end
    end

    def set_styles
      data_cell[:properties] ||= data_cell[:style] || data_cell[:styles]
      set_attributes self, data_cell[:properties] if data_cell[:properties]
    end

    def set_title
      set_attributed_text(self.textLabel, data_cell[:title]) if data_cell[:title]
    end

    def set_subtitle
      return unless data_cell[:subtitle] && self.detailTextLabel
      set_attributed_text(self.detailTextLabel, data_cell[:subtitle])
      self.detailTextLabel.backgroundColor = UIColor.clearColor
      self.detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth
    end

    def set_remote_image
      return unless data_cell[:remote_image] && jm_image_cache?

      self.imageView.image = remote_placeholder
      JMImageCache.sharedCache.imageForURL(data_cell[:remote_image][:url].to_url, completionBlock:proc { |downloaded_image|
        self.imageView.image = downloaded_image
        self.setNeedsLayout
      })

      self.imageView.layer.masksToBounds = true
      self.imageView.layer.cornerRadius = data_cell[:remote_image][:radius] if data_cell[:remote_image][:radius]
      self.imageView.contentMode = map_content_mode_symbol(data_cell[:remote_image][:content_mode]) if data_cell[:remote_image][:content_mode]
    end

    def set_image
      return unless data_cell[:image]
      cell_image = data_cell[:image].is_a?(Hash) ? data_cell[:image][:image] : data_cell[:image]
      cell_image = UIImage.imageNamed(cell_image) if cell_image.is_a?(String)
      self.imageView.layer.masksToBounds = true
      self.imageView.image = cell_image
      self.imageView.layer.cornerRadius = data_cell[:image][:radius] if data_cell[:image].is_a?(Hash) && data_cell[:image][:radius]
    end

    def set_accessory_view
      return self.accessoryView = nil unless data_cell[:accessory] && data_cell[:accessory][:view]
      if data_cell[:accessory][:view] == :switch
        self.accessoryView = switch_view
      else
        if data_cell[:accessory][:view].superview && data_cell[:accessory][:view].superview.is_a?(UITableViewCell)
          data_cell[:accessory][:view].superview.accessoryView = nil # Fix for issue #586
        end
        self.accessoryView = data_cell[:accessory][:view]
        self.accessoryView.autoresizingMask = UIViewAutoresizingFlexibleWidth
      end
    end

    def set_selection_style
      self.selectionStyle = map_selection_style_symbol(data_cell[:selection_style]) if data_cell[:selection_style]
    end

    def set_accessory_type
      self.accessoryType = map_accessory_type_symbol(data_cell[:accessory_type]) if data_cell[:accessory_type]
    end

  private

    def jm_image_cache?
      return false if RUBYMOTION_ENV == 'test'
      return true if self.imageView.respond_to?("setImageWithURL:placeholder:")
      PM.logger.error "ProMotion Warning: to use remote_image with TableScreen you need to include the CocoaPod 'JMImageCache'."
      false
    end

    def remote_placeholder
      UIImage.imageNamed(data_cell[:remote_image][:placeholder]) if data_cell[:remote_image][:placeholder].is_a?(String)
    end

    def switch_view
      switch = UISwitch.alloc.initWithFrame(CGRectZero)
      switch.setAccessibilityLabel(data_cell[:accessory][:accessibility_label] || data_cell[:title])
      switch.addTarget(self.table_screen, action: "accessory_toggled_switch:", forControlEvents:UIControlEventValueChanged)
      switch.on = !!data_cell[:accessory][:value]
      switch
    end

    def set_attributed_text(label, text)
      text.is_a?(NSAttributedString) ? label.attributedText = text : label.text = text
    end

    def map_content_mode_symbol(symbol)
      {
        scale_to_fill:     UIViewContentModeScaleToFill,
        scale_aspect_fit:  UIViewContentModeScaleAspectFit,
        scale_aspect_fill: UIViewContentModeScaleAspectFill,
        mode_redraw:       UIViewContentModeRedraw
      }[symbol] || symbol
    end

    def map_selection_style_symbol(symbol)
      {
        none:     UITableViewCellSelectionStyleNone,
        blue:     UITableViewCellSelectionStyleBlue,
        gray:     UITableViewCellSelectionStyleGray,
        default:  UITableViewCellSelectionStyleDefault
      }[symbol] || symbol
    end

    def map_accessory_type_symbol(symbol)
      {
        none:                 UITableViewCellAccessoryNone,
        disclosure_indicator: UITableViewCellAccessoryDisclosureIndicator,
        disclosure_button:    UITableViewCellAccessoryDetailDisclosureButton,
        checkmark:            UITableViewCellAccessoryCheckmark,
        detail_button:        UITableViewCellAccessoryDetailButton
      }[symbol] || symbol
    end
  end
end

# ========================================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/cocoatouch/table_view_cell.rb
# ========================================================================
module ProMotion
  class TableViewCell < UITableViewCell
    include TableViewCellModule
  end
end

# ===========================================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/cocoatouch/tab_bar_controller.rb
# ===========================================================================
module ProMotion
  class TabBarController < UITabBarController

    attr_accessor :pm_tab_delegate

    def self.new(*screens)
      tab_bar_controller = alloc.init

      screens = screens.flatten.map { |s| s.respond_to?(:new) ? s.new : s } # Initialize any classes

      tag_index = 0
      view_controllers = screens.map do |s|
        s.tabBarItem.tag = tag_index
        s.tab_bar = WeakRef.new(tab_bar_controller) if s.respond_to?("tab_bar=")
        tag_index += 1
        s.navigationController || s
      end

      tab_bar_controller.viewControllers = view_controllers
      tab_bar_controller.delegate = tab_bar_controller
      tab_bar_controller
    end

    def open_tab(tab)
      if tab.is_a? String
        selected_tab_vc = find_tab(tab)
      elsif tab.is_a? Numeric
        selected_tab_vc = viewControllers[tab]
      end

      if selected_tab_vc
        self.selectedViewController = selected_tab_vc
        on_tab_selected_try(selected_tab_vc)

        selected_tab_vc
      else
        PM.logger.error "Unable to open tab #{tab.to_s} -- not found."
        nil
      end
    end

    def find_tab(tab_title)
      viewControllers.find { |vc| vc.tabBarItem.title == tab_title }
    end

    # Cocoa touch methods below
    def tabBarController(tbc, didSelectViewController: vc)
      on_tab_selected_try(vc)
    end

    def shouldAutorotate
      current_view_controller_try(:shouldAutorotate)
    end

    def supportedInterfaceOrientations
      current_view_controller_try(:supportedInterfaceOrientations)
    end

    def preferredInterfaceOrientationForPresentation
      current_view_controller_try(:preferredInterfaceOrientationForPresentation)
    end

    private

    def on_tab_selected_try(vc)
      if pm_tab_delegate && pm_tab_delegate.respond_to?(:weakref_alive?) && pm_tab_delegate.weakref_alive? && pm_tab_delegate.respond_to?("on_tab_selected:")
        pm_tab_delegate.send(:on_tab_selected, vc)
      end
    end

    def current_view_controller
      selectedViewController || viewControllers.first
    end

    def current_view_controller_try(method, *args)
      current_view_controller.send(method, *args) if current_view_controller.respond_to?(method)
    end

  end
end

# =======================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/tabs/tabs.rb
# =======================================================
module ProMotion
  module Tabs
    attr_accessor :tab_bar, :tab_bar_item

    def open_tab_bar(*screens)
      self.tab_bar = PM::TabBarController.new(screens)
      self.tab_bar.pm_tab_delegate = WeakRef.new(self)

      delegate = self.respond_to?(:open_root_screen) ? self : UIApplication.sharedApplication.delegate

      delegate.open_root_screen(self.tab_bar)
      self.tab_bar
    end

    def open_tab(tab)
      self.tab_bar.open_tab(tab)
    end

    def set_tab_bar_item(args = {})
      self.tab_bar_item = args
      refresh_tab_bar_item
    end

    def refresh_tab_bar_item
      self.tabBarItem = create_tab_bar_item(self.tab_bar_item) if self.tab_bar_item && self.respond_to?("tabBarItem=")
    end

    def set_tab_bar_badge(number)
      self.tab_bar_item[:badge_number] = number
      refresh_tab_bar_item
    end

    def create_tab_bar_item_custom(title, item_image, tag)
      if item_image.is_a?(String)
        item_image = UIImage.imageNamed(item_image)
      elsif item_image.is_a?(Hash)
        item_selected = item_image[:selected]
        item_unselected = item_image[:unselected]
        item_image = nil
      end

      item = UITabBarItem.alloc.initWithTitle(title, image: item_image, tag: tag)

      if item_selected || item_unselected
        item.image = item_unselected
        item.selectedImage = item_selected
      end

      item
    end

    def create_tab_bar_item(tab={})
      if tab[:system_icon] || tab[:icon]
        PM.logger.deprecated("`system_icon:` no longer supported. Use `system_item:` instead.") if tab[:system_icon]
        PM.logger.deprecated("`icon:` no longer supported. Use `item:` instead.") if tab[:icon]
        tab[:system_item] ||= tab[:system_icon]
        tab[:item] ||= tab[:icon]
      end

      unless tab[:system_item] || tab[:item]
        PM.logger.warn("You must provide either a `system_item:` or custom `item:` in `tab_bar_item`")
        abort
      end

      title = tab[:title] || "Untitled"

      tab_bar_item = UITabBarItem.alloc.initWithTabBarSystemItem(map_tab_symbol(tab[:system_item]), tag: current_tag) if tab[:system_item]
      tab_bar_item = create_tab_bar_item_custom(title, tab[:item], current_tag) if tab[:item]

      tab_bar_item.badgeValue = tab[:badge_number].to_s unless tab[:badge_number].nil? || tab[:badge_number] <= 0
      tab_bar_item.imageInsets = tab[:image_insets] if tab[:image_insets]

      tab_bar_item
    end

    def current_tag
      return @prev_tag = 0 unless @prev_tag
      @prev_tag += 1
    end

    def replace_current_item(tab_bar_controller, view_controller: vc)
      controllers = NSMutableArray.arrayWithArray(tab_bar_controller.viewControllers)
      controllers.replaceObjectAtIndex(tab_bar_controller.selectedIndex, withObject: vc)
      tab_bar_controller.viewControllers = controllers
    end

    def map_tab_symbol(symbol)
      @_tab_symbols ||= {
        more:         UITabBarSystemItemMore,
        favorites:    UITabBarSystemItemFavorites,
        featured:     UITabBarSystemItemFeatured,
        top_rated:    UITabBarSystemItemTopRated,
        recents:      UITabBarSystemItemRecents,
        contacts:     UITabBarSystemItemContacts,
        history:      UITabBarSystemItemHistory,
        bookmarks:    UITabBarSystemItemBookmarks,
        search:       UITabBarSystemItemSearch,
        downloads:    UITabBarSystemItemDownloads,
        most_recent:  UITabBarSystemItemMostRecent,
        most_viewed:  UITabBarSystemItemMostViewed
      }
      @_tab_symbols[symbol] || symbol
    end

    module TabClassMethods
      def tab_bar_item(args={})
        @tab_bar_item = args
      end

      def get_tab_bar_item
        @tab_bar_item
      end
    end

    def self.included(base)
      base.extend(TabClassMethods)
    end

  end
end

# ==============================================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/cocoatouch/table_view_controller.rb
# ==============================================================================
module ProMotion
  class TableViewController < UITableViewController
    def self.new(args = {})
      s = self.alloc.initWithStyle(table_style)
      s.screen_init(args) if s.respond_to?(:screen_init)
      s
    end

    def loadView
      self.respond_to?(:load_view) ? self.load_view : super
    end

    def viewDidLoad
      super
      self.view_did_load if self.respond_to?(:view_did_load)
    end

    def viewWillAppear(animated)
      super
      self.view_will_appear(animated) if self.respond_to?("view_will_appear:")
    end

    def viewDidAppear(animated)
      super
      self.view_did_appear(animated) if self.respond_to?("view_did_appear:")
    end

    def viewWillDisappear(animated)
      self.view_will_disappear(animated) if self.respond_to?("view_will_disappear:")
      super
    end

    def viewDidDisappear(animated)
      self.view_did_disappear(animated) if self.respond_to?("view_did_disappear:")
      super
    end

    def shouldAutorotateToInterfaceOrientation(orientation)
      self.should_rotate(orientation)
    end

    def shouldAutorotate
      self.should_autorotate
    end

    def willRotateToInterfaceOrientation(orientation, duration:duration)
      self.will_rotate(orientation, duration)
    end

    def didRotateFromInterfaceOrientation(orientation)
      self.on_rotate
    end
  end
end

# ========================================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/cocoatouch/view_controller.rb
# ========================================================================
module ProMotion
  class ViewController < UIViewController
    def self.new(args = {})
      s = self.alloc.initWithNibName(args[:nib_name] || nil, bundle:args[:bundle] || nil)
      s.screen_init(args) if s.respond_to?(:screen_init)
      s
    end

    def loadView
      self.respond_to?(:load_view) ? self.load_view : super
    end

    def viewDidLoad
      super
      self.view_did_load if self.respond_to?(:view_did_load)
    end

    def viewWillAppear(animated)
      super
      self.view_will_appear(animated) if self.respond_to?("view_will_appear:")
    end

    def viewDidAppear(animated)
      super
      self.view_did_appear(animated) if self.respond_to?("view_did_appear:")
    end

    def viewWillDisappear(animated)
      self.view_will_disappear(animated) if self.respond_to?("view_will_disappear:")
      super
    end

    def viewDidDisappear(animated)
      self.view_did_disappear(animated) if self.respond_to?("view_did_disappear:")
      super
    end

    def shouldAutorotateToInterfaceOrientation(orientation)
      self.should_rotate(orientation)
    end

    def shouldAutorotate
      self.should_autorotate
    end

    def willRotateToInterfaceOrientation(orientation, duration:duration)
      self.will_rotate(orientation, duration)
    end

    def didRotateFromInterfaceOrientation(orientation)
      self.on_rotate
    end
  end
end

# =============================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/support/support.rb
# =============================================================
module ProMotion
  module Support

    def app
      UIApplication.sharedApplication
    end

    def app_delegate
      UIApplication.sharedApplication.delegate
    end

    def app_window
      UIApplication.sharedApplication.delegate.window
    end

    def try(method, *args)
      send(method, *args) if respond_to?(method)
    end

  end
end

# ===============================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/ipad/split_screen.rb
# ===============================================================
module ProMotion
  module SplitScreen
    def open_split_screen(master, detail, args={})
      split = create_split_screen(master, detail, args)
      open split, args
      split
    end

    def create_split_screen(master, detail, args={})
      master = master.new if master.respond_to?(:new)
      detail = detail.new if detail.respond_to?(:new)
      split = split_screen_controller(master, detail)
      split_screen_setup(split, args)
      split
    end

    # UISplitViewControllerDelegate methods

    # iOS 7 and below
    def splitViewController(svc, willHideViewController: vc, withBarButtonItem: button, forPopoverController: _)
      button ||= self.displayModeButtonItem if self.respond_to?(:displayModeButtonItem)
      return unless button
      button.title = @pm_split_screen_button_title || vc.title
      svc.detail_screen.navigationItem.leftBarButtonItem = button
    end

    def splitViewController(svc, willShowViewController: _, invalidatingBarButtonItem: _)
      svc.detail_screen.navigationItem.leftBarButtonItem = nil
    end

    # iOS 8 and above
    def splitViewController(svc, willChangeToDisplayMode: display_mode)
      vc = svc.viewControllers.first
      vc = vc.topViewController if vc.respond_to?(:topViewController)
      case display_mode
      # when UISplitViewControllerDisplayModeAutomatic then do_something?
      when UISplitViewControllerDisplayModePrimaryHidden
        self.splitViewController(svc, willHideViewController: vc, withBarButtonItem: nil, forPopoverController: nil)
        # TODO: Add `self.master_screen.try(:will_hide_split_screen)` or similar?
      when UISplitViewControllerDisplayModeAllVisible
        self.splitViewController(svc, willShowViewController: vc, invalidatingBarButtonItem: nil)
        # TODO: Add `self.master_screen.try(:will_show_split_screen)` or similar?
      # when UISplitViewControllerDisplayModePrimaryOverlay
        # TODO: Add `self.master_screen.try(:will_show_split_screen_overlay)` or similar?
      end
    end

  private

    def split_screen_controller(master, detail)
      split = SplitViewController.alloc.init
      split.viewControllers = [ (master.navigationController || master), (detail.navigationController || detail) ]
      split.delegate = self

      [ master, detail ].map { |s| s.split_screen = split if s.respond_to?(:split_screen=) }

      split
    end

    def split_screen_setup(split, args)
      args[:icon] ||= args[:item] # TODO: Remove in PM 2.2+.
      if (args[:item] || args[:title]) && respond_to?(:create_tab_bar_item)
        split.tabBarItem = create_tab_bar_item(args)
      end
      @pm_split_screen_button_title = args[:button_title] if args.has_key?(:button_title)
      split.presentsWithGesture = args[:swipe] if args.has_key?(:swipe)
    end

  end

end

# ======================================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/delegate/delegate_parent.rb
# ======================================================================
module ProMotion
  # This is a workaround to a RubyMotion bug that displays an error message when calling
  # `super` from application:didFinishLaunchingWithOptions: (which you sometimes need to
  # do when using a custom AppDelegate parent class).
  # See issue: https://github.com/clearsightstudio/ProMotion/issues/116
  class DelegateParent
    def application(application, didFinishLaunchingWithOptions:options)
      true
    end
  end
end

# ======================================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/delegate/delegate_module.rb
# ======================================================================
module ProMotion
  module DelegateModule
    include ProMotion::Support
    include ProMotion::Tabs
    include ProMotion::SplitScreen if UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad

    attr_accessor :window, :home_screen

    def application(application, willFinishLaunchingWithOptions:launch_options)
      will_load(application, launch_options) if respond_to?(:will_load)
      true
    end

    def application(application, didFinishLaunchingWithOptions:launch_options)
      apply_status_bar
      on_load application, launch_options
      # Requires 'ProMotion-push' gem.
      check_for_push_notification(launch_options) if respond_to?(:check_for_push_notification)
      super rescue true # Can cause error message if no super is found, but it's harmless. Ignore.
    end

    def applicationDidBecomeActive(application)
      try :on_activate
    end

    def applicationWillResignActive(application)
      try :will_deactivate
    end

    def applicationDidEnterBackground(application)
      try :on_enter_background
    end

    def applicationWillEnterForeground(application)
      try :will_enter_foreground
    end

    def applicationWillTerminate(application)
      try :on_unload
    end

    def application(application, openURL: url, sourceApplication:source_app, annotation: annotation)
      try :on_open_url, { url: url, source_app: source_app, annotation: annotation }
    end

    def ui_window
      (defined?(Motion) && defined?(Motion::Xray) && defined?(Motion::Xray::XrayWindow)) ? Motion::Xray::XrayWindow : UIWindow
    end

    def open(screen, args={})
      screen = screen.new if screen.respond_to?(:new)

      self.home_screen = screen

      self.window ||= self.ui_window.alloc.initWithFrame(UIScreen.mainScreen.bounds)
      self.window.rootViewController = (screen.navigationController || screen)
      self.window.tintColor = self.class.send(:get_tint_color) if self.window.respond_to?("tintColor=")
      self.window.makeKeyAndVisible

      screen
    end
    alias :open_screen :open
    alias :open_root_screen :open_screen

    def status_bar?
      UIApplication.sharedApplication.statusBarHidden
    end

  private

    def apply_status_bar
      self.class.send(:apply_status_bar)
    end

  public

    module ClassMethods

      def status_bar(visible = true, opts={})
        @status_bar_visible = visible
        @status_bar_opts = opts
      end

      def apply_status_bar
        @status_bar_visible = true if @status_bar_visible.nil?
        @status_bar_opts ||= { animation: :none }
        UIApplication.sharedApplication.setStatusBarHidden(!@status_bar_visible, withAnimation:status_bar_animation(@status_bar_opts[:animation]))
      end

      def status_bar_animation(opt)
        {
          fade:   UIStatusBarAnimationFade,
          slide:  UIStatusBarAnimationSlide,
          none:   UIStatusBarAnimationNone
        }[opt] || UIStatusBarAnimationNone
      end

      def tint_color(c)
        @tint_color = c
      end

      def tint_color=(c)
        @tint_color = c
      end

      def get_tint_color
        @tint_color || nil
      end

    end

    def self.included(base)
      base.extend(ClassMethods)
    end

  end
end

# ===============================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/delegate/delegate.rb
# ===============================================================
module ProMotion
  class Delegate < DelegateParent
    include ProMotion::DelegateModule
  end
end

# ======================================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/screen/screen_navigation.rb
# ======================================================================
module ProMotion
  module ScreenNavigation
    include ProMotion::Support

    def open_screen(screen, args = {})
      args = { animated: true }.merge(args)

      # Apply properties to instance
      screen = set_up_screen_for_open(screen, args)
      ensure_wrapper_controller_in_place(screen, args)

      opened ||= open_in_split_screen(screen, args) if self.split_screen
      opened ||= open_root_screen(screen) if args[:close_all]
      opened ||= present_modal_view_controller(screen, args) if args[:modal]
      opened ||= open_in_tab(screen, args[:in_tab]) if args[:in_tab]
      opened ||= push_view_controller(screen, self.navigationController, !!args[:animated]) if self.navigationController
      opened ||= open_root_screen(screen.navigationController || screen)
      screen
    end
    alias :open :open_screen

    def open_in_split_screen(screen, args)
      self.split_screen.detail_screen = screen if args[:in_detail]
      self.split_screen.master_screen = screen if args[:in_master]
      args[:in_detail] || args[:in_master]
    end

    def open_root_screen(screen)
      app_delegate.open_root_screen(screen)
    end

    def open_modal(screen, args = {})
      open screen, args.merge({ modal: true })
    end

    def close_screen(args = {})
      args ||= {}
      args = { sender: args } unless args.is_a?(Hash)
      args[:animated] = true unless args.has_key?(:animated)

      if self.modal?
        close_nav_screen args if self.navigationController
        close_modal_screen args

      elsif self.navigationController
        close_nav_screen args
        send_on_return(args)

      else
        PM.logger.warn "Tried to close #{self.to_s}; however, this screen isn't modal or in a nav bar."

      end
    end
    alias :close :close_screen

    def send_on_return(args = {})
      return unless self.parent_screen
      if self.parent_screen.respond_to?(:on_return)
        if args && self.parent_screen.method(:on_return).arity != 0
          self.parent_screen.send(:on_return, args)
        else
          self.parent_screen.send(:on_return)
        end
      elsif self.parent_screen.private_methods.include?(:on_return)
        PM.logger.warn "#{self.parent_screen.inspect} has an `on_return` method, but it is private and not callable from the closing screen."
      end
    end

    def push_view_controller(vc, nav_controller=nil, animated=true)
      unless self.navigationController
        PM.logger.error "You need a nav_bar if you are going to push #{vc.to_s} onto it."
      end
      nav_controller ||= self.navigationController
      return if nav_controller.topViewController == vc
      vc.first_screen = false if vc.respond_to?(:first_screen=)
      nav_controller.pushViewController(vc, animated: animated)
    end

  protected

    def set_up_screen_for_open(screen, args={})

      # Instantiate screen if given a class
      screen = screen.new if screen.respond_to?(:new)

      # Set parent
      screen.parent_screen = self if screen.respond_to?(:parent_screen=)

      # Set title & modal properties
      screen.title = args[:title] if args[:title] && screen.respond_to?(:title=)
      screen.modal = args[:modal] if args[:modal] && screen.respond_to?(:modal=)

      # Hide bottom bar?
      screen.hidesBottomBarWhenPushed = args[:hide_tab_bar] == true

      # Wrap in a PM::NavigationController?
      screen.add_nav_bar(args) if args[:nav_bar] && screen.respond_to?(:add_nav_bar)

      # Return modified screen instance
      screen

    end

    def ensure_wrapper_controller_in_place(screen, args={})
      unless args[:close_all] || args[:modal] || args[:in_detail] || args[:in_master]
        screen.navigationController ||= self.navigationController if screen.respond_to?("navigationController=")
        screen.tab_bar ||= self.tab_bar if screen.respond_to?("tab_bar=")
      end
    end

    def present_modal_view_controller(screen, args={})
      self.presentViewController((screen.navigationController || screen), animated: args[:animated], completion: args[:completion])
    end

    def open_in_tab(screen, tab_name)
      vc = open_tab(tab_name)
      return PM.logger.error("No tab bar item '#{tab_name}'") && nil unless vc
      if vc.is_a?(UINavigationController)
        push_view_controller(screen, vc)
      else
        replace_view_controller(screen, vc)
      end
    end

    def replace_view_controller(new_vc, old_vc)
      self.tab_bar.viewControllers = self.tab_bar.viewControllers.map do |vc|
        vc == old_vc ? new_vc : vc
      end
    end

    def close_modal_screen(args={})
      args[:animated] = true unless args.has_key?(:animated)
      self.parent_screen.dismissViewControllerAnimated(args[:animated], completion: lambda {
        send_on_return(args)
      })
    end

    def close_nav_screen(args={})
      args[:animated] = true unless args.has_key?(:animated)
      if args[:to_screen] == :root
        self.parent_screen = self.navigationController.viewControllers.first
        self.navigationController.popToRootViewControllerAnimated args[:animated]
      elsif args[:to_screen] && args[:to_screen].is_a?(UIViewController)
        self.parent_screen = args[:to_screen]
        self.navigationController.popToViewController(args[:to_screen], animated: args[:animated])
      else
        self.navigationController.popViewControllerAnimated(args[:animated])
      end
      self.navigationController = nil
    end

  end
end

# ===================================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/screen/nav_bar_module.rb
# ===================================================================
module ProMotion
  module NavBarModule

    def nav_bar?
      !!self.navigationController
    end

    def navigation_controller
      self.navigationController
    end

    def navigation_controller=(nav)
      self.navigationController = nav
    end

    def navigationController=(nav)
      @navigationController = nav
    end

    def set_nav_bar_button(side, args={})
      button = (args.is_a?(UIBarButtonItem)) ? args : create_toolbar_button(args)
      button.setTintColor args[:tint_color] if args.is_a?(Hash) && args[:tint_color]

      self.navigationItem.leftBarButtonItem = button if side == :left
      self.navigationItem.rightBarButtonItem = button if side == :right
      self.navigationItem.backBarButtonItem = button if side == :back

      button
    end

    def set_nav_bar_buttons(side, buttons=[])
      buttons = buttons.map{ |b| b.is_a?(UIBarButtonItem) ? b : create_toolbar_button(b) }.reverse

      self.navigationItem.setLeftBarButtonItems(buttons) if side == :left
      self.navigationItem.setRightBarButtonItems(buttons) if side == :right
    end

    # TODO: In PM 2.1+, entirely remove this deprecated method.
    def set_nav_bar_left_button(title, args={})
      PM.logger.deprecated "set_nav_bar_right_button and set_nav_bar_left_button have been removed. Use set_nav_bar_button :right/:left instead."
    end
    alias_method :set_nav_bar_right_button, :set_nav_bar_left_button

    def set_toolbar_items(buttons = [], animated = true)
      if buttons
        self.toolbarItems = Array(buttons).map{|b| b.is_a?(UIBarButtonItem) ? b : create_toolbar_button(b) }
        navigationController.setToolbarHidden(false, animated:animated)
      else
        navigationController.setToolbarHidden(true, animated:animated)
      end
    end
    alias_method :set_toolbar_buttons, :set_toolbar_items
    alias_method :set_toolbar_button,  :set_toolbar_items

    def add_nav_bar(args = {})
      self.navigationController ||= begin
        self.first_screen = true if self.respond_to?(:first_screen=)
        nav = (args[:nav_controller] || NavigationController).alloc.initWithRootViewController(self)
        nav.setModalTransitionStyle(args[:transition_style]) if args[:transition_style]
        nav.setModalPresentationStyle(args[:presentation_style]) if args[:presentation_style]
        nav
      end
      self.navigationController.toolbarHidden = !args[:toolbar] unless args[:toolbar].nil?
      self.navigationController.setNavigationBarHidden(args[:hide_nav_bar], animated: false) unless args[:hide_nav_bar].nil?
    end

  private

    def create_toolbar_button(args = {})
      button_type = args[:image] || args[:button] || args[:custom_view] || args[:title] || "Button"
      bar_button_item button_type, args
    end

    def bar_button_item(button_type, args)
      return PM.logger.deprecated("`system_icon:` no longer supported. Use `system_item:` instead.") if args[:system_icon]
      return button_type if button_type.is_a?(UIBarButtonItem)
      return bar_button_item_system_item(args) if args[:system_item]
      return bar_button_item_image(button_type, args) if button_type.is_a?(UIImage)
      return bar_button_item_string(button_type, args) if button_type.is_a?(String)
      return bar_button_item_custom(button_type) if button_type.is_a?(UIView)
      PM.logger.error("Please supply a title string, a UIImage or :system.") && nil
    end

    def bar_button_item_image(img, args)
      button = UIBarButtonItem.alloc.initWithImage(img, style: map_bar_button_item_style(args[:style]), target: args[:target] || self, action: args[:action])
      button.setTintColor args[:tint_color] if args[:tint_color]
      button
    end

    def bar_button_item_string(str, args)
      button = UIBarButtonItem.alloc.initWithTitle(str, style: map_bar_button_item_style(args[:style]), target: args[:target] || self, action: args[:action])
      button.setTintColor args[:tint_color] if args[:tint_color]
      button
    end

    def bar_button_item_system_item(args)
      button = UIBarButtonItem.alloc.initWithBarButtonSystemItem(map_bar_button_system_item(args[:system_item]), target: args[:target] || self, action: args[:action])
      button.setTintColor args[:tint_color] if args[:tint_color]
      button
    end

    def bar_button_item_custom(custom_view)
      UIBarButtonItem.alloc.initWithCustomView(custom_view)
    end

    def map_bar_button_system_item(symbol)
      {
        done:         UIBarButtonSystemItemDone,
        cancel:       UIBarButtonSystemItemCancel,
        edit:         UIBarButtonSystemItemEdit,
        save:         UIBarButtonSystemItemSave,
        add:          UIBarButtonSystemItemAdd,
        flexible_space: UIBarButtonSystemItemFlexibleSpace,
        fixed_space:    UIBarButtonSystemItemFixedSpace,
        compose:      UIBarButtonSystemItemCompose,
        reply:        UIBarButtonSystemItemReply,
        action:       UIBarButtonSystemItemAction,
        organize:     UIBarButtonSystemItemOrganize,
        bookmarks:    UIBarButtonSystemItemBookmarks,
        search:       UIBarButtonSystemItemSearch,
        refresh:      UIBarButtonSystemItemRefresh,
        stop:         UIBarButtonSystemItemStop,
        camera:       UIBarButtonSystemItemCamera,
        trash:        UIBarButtonSystemItemTrash,
        play:         UIBarButtonSystemItemPlay,
        pause:        UIBarButtonSystemItemPause,
        rewind:       UIBarButtonSystemItemRewind,
        fast_forward: UIBarButtonSystemItemFastForward,
        undo:         UIBarButtonSystemItemUndo,
        redo:         UIBarButtonSystemItemRedo,
        page_curl:    UIBarButtonSystemItemPageCurl
      }[symbol] ||    UIBarButtonSystemItemDone
    end

    def map_bar_button_item_style(symbol)
      {
        plain:     UIBarButtonItemStylePlain,
        bordered:  UIBarButtonItemStyleBordered,
        done:      UIBarButtonItemStyleDone
      }[symbol] || UIBarButtonItemStyleDone
    end

  end
end

# ===========================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/logger/logger.rb
# ===========================================================
module ProMotion
  class Logger
    attr_accessor :level

    NAME = "ProMotion::Logger: "

    COLORS = {
      default:    [ '', '' ],
      red:        [ "\e[0;31m", "\e[0m" ],
      green:      [ "\e[0;32m", "\e[0m" ],
      yellow:     [ "\e[0;33m", "\e[0m" ],
      blue:       [ "\e[0;34m", "\e[0m" ],
      purple:     [ "\e[0;35m", "\e[0m" ],
      cyan:       [ "\e[0;36m", "\e[0m" ]
    }

    LEVELS = {
      off:        [],
      error:      [:error],
      warn:       [:error, :warn],
      info:       [:error, :warn, :info],
      debug:      [:error, :warn, :info, :debug],
      verbose:    [:error, :warn, :info, :debug, :verbose],
    }

    def level
      @level ||= (RUBYMOTION_ENV == "release" ? :error : :debug)
    end

    def level=(new_level)
      log('LOG LEVEL', 'Setting PM.logger to :verbose will make everything REALLY SLOW!', :purple) if new_level == :verbose
      @level = new_level
    end

    def levels
      LEVELS[self.level] || []
    end

    # Usage: PM.logger.log("ERROR", "message here", :red)
    def log(label, message_text, color)
      # return if defined?(RUBYMOTION_ENV) && RUBYMOTION_ENV == "test"
      color = COLORS[color] || COLORS[:default]
      $stderr.puts color[0] + NAME + "[#{label}] #{message_text}" + color[1]
      nil
    end

    def error(message)
      log('ERROR', message, :red) if self.levels.include?(:error)
    end

    def deprecated(message)
      log('DEPRECATED', message, :yellow) if self.levels.include?(:warn)
    end

    def warn(message)
      log('WARN', message, :yellow) if self.levels.include?(:warn)
    end

    def debug(message)
      log('DEBUG', message, :purple) if self.levels.include?(:debug)
    end

    def info(message)
      log('INFO', message, :green) if self.levels.include?(:info)
    end

  end

  module_function

  def logger
    @logger ||= Logger.new
  end

  def logger=(log)
    @logger = log
  end

end

# ========================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/pro_motion.rb
# ========================================================
module ProMotion
end
::PM = ProMotion unless defined?(::PM)

# ==============================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/stubs/dummy_view.rb
# ==============================================================
class DummyView < UIView
  private

  def dummy
    setFrame(nil)
  end
end

# ====================================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/stubs/dummy_image_view.rb
# ====================================================================
class DummyImageView < UIImageView
private

  def dummy
    imageForURL(nil, completionBlock:nil)
  end
end
# ==================================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/screen/screen_module.rb
# ==================================================================
module ProMotion
  module ScreenModule
    include ProMotion::Support
    include ProMotion::ScreenNavigation
    include ProMotion::Styling
    include ProMotion::NavBarModule
    include ProMotion::Tabs
    include ProMotion::SplitScreen if UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad

    attr_accessor :parent_screen, :first_screen, :modal, :split_screen

    def screen_init(args = {})
      check_ancestry
      resolve_title
      apply_properties(args)
      add_nav_bar(args) if args[:nav_bar]
      add_nav_bar_buttons
      tab_bar_setup
      try :on_init
      try :screen_setup
      PM.logger.deprecated "In #{self.class.to_s}, #on_create has been deprecated and removed. Use #screen_init instead." if respond_to?(:on_create)
    end

    def modal?
      self.modal == true
    end

    def resolve_title
      case self.class.title_type
      when :text then self.title = self.class.title
      when :view then self.navigationItem.titleView = self.class.title
      when :image then self.navigationItem.titleView = UIImageView.alloc.initWithImage(self.class.title)
      else
        PM.logger.warn("title expects string, UIView, or UIImage, but #{self.class.title.class.to_s} given.")
      end
    end

    def resolve_status_bar
      case self.class.status_bar_type
      when :none
        status_bar_hidden true
      when :light
        status_bar_hidden false
        status_bar_style UIStatusBarStyleLightContent
      else
        status_bar_hidden false
        status_bar_style UIStatusBarStyleDefault
      end
    end

    def add_nav_bar_buttons
      set_nav_bar_button(self.class.get_nav_bar_button[:side], self.class.get_nav_bar_button) if self.class.get_nav_bar_button
    end

    def status_bar_hidden(hidden)
      UIApplication.sharedApplication.setStatusBarHidden(hidden, withAnimation:self.class.status_bar_animation)
    end

    def status_bar_style(style)
      UIApplication.sharedApplication.setStatusBarStyle(style)
    end

    def parent_screen=(parent)
      @parent_screen = WeakRef.new(parent)
    end

    def first_screen?
      self.first_screen == true
    end

    def view_did_load
      self.send(:on_load) if self.respond_to?(:on_load)
    end

    def view_will_appear(animated)
      resolve_status_bar
      self.will_appear

      self.will_present if isMovingToParentViewController
    end
    def will_appear; end
    def will_present; end

    def view_did_appear(animated)
      self.on_appear

      self.on_present if isMovingToParentViewController
    end
    def on_appear; end
    def on_present; end

    def view_will_disappear(animated)
      self.will_disappear

      self.will_dismiss if isMovingFromParentViewController
    end
    def will_disappear; end
    def will_dismiss; end

    def view_did_disappear(animated)
      self.on_disappear

      self.on_dismiss if isMovingFromParentViewController
    end
    def on_disappear; end
    def on_dismiss; end

    def should_rotate(orientation)
      case orientation
      when UIInterfaceOrientationPortrait
        return supported_orientation?("UIInterfaceOrientationPortrait")
      when UIInterfaceOrientationLandscapeLeft
        return supported_orientation?("UIInterfaceOrientationLandscapeLeft")
      when UIInterfaceOrientationLandscapeRight
        return supported_orientation?("UIInterfaceOrientationLandscapeRight")
      when UIInterfaceOrientationPortraitUpsideDown
        return supported_orientation?("UIInterfaceOrientationPortraitUpsideDown")
      else
        false
      end
    end

    def will_rotate(orientation, duration)
    end

    def should_autorotate
      true
    end

    def on_rotate
    end

    def supported_orientations
      orientations = 0
      NSBundle.mainBundle.infoDictionary["UISupportedInterfaceOrientations"].each do |ori|
        case ori
        when "UIInterfaceOrientationPortrait"
          orientations |= UIInterfaceOrientationMaskPortrait
        when "UIInterfaceOrientationLandscapeLeft"
          orientations |= UIInterfaceOrientationMaskLandscapeLeft
        when "UIInterfaceOrientationLandscapeRight"
          orientations |= UIInterfaceOrientationMaskLandscapeRight
        when "UIInterfaceOrientationPortraitUpsideDown"
          orientations |= UIInterfaceOrientationMaskPortraitUpsideDown
        end
      end
      orientations
    end

    def supported_orientation?(orientation)
      NSBundle.mainBundle.infoDictionary["UISupportedInterfaceOrientations"].include?(orientation)
    end

    def supported_device_families
      NSBundle.mainBundle.infoDictionary["UIDeviceFamily"].map do |m|
        {
          "1" => :iphone,
          "2" => :ipad
        }[m] || :unknown_device
      end
    end

    def supported_device_family?(family)
      supported_device_families.include?(family)
    end

    def bounds
      return self.view_or_self.bounds
    end

    def frame
      return self.view_or_self.frame
    end

  private

    def apply_properties(args)
      reserved_args = [ :nav_bar, :hide_nav_bar, :hide_tab_bar, :animated, :close_all, :in_tab, :in_detail, :in_master, :to_screen ]
      set_attributes self, args.dup.delete_if { |k,v| reserved_args.include?(k) }
    end

    def tab_bar_setup
      self.tab_bar_item = self.class.send(:get_tab_bar_item)
      self.refresh_tab_bar_item if self.tab_bar_item
    end

    def check_ancestry
      unless self.is_a?(UIViewController)
        raise StandardError.new("ERROR: Screens must extend UIViewController or a subclass of UIViewController.")
      end
    end

    # Class methods
    module ClassMethods
      def title(t=nil)
        if t && t.is_a?(String) == false
          PM.logger.deprecated "You're trying to set the title of #{self.to_s} to an instance of #{t.class.to_s}. In ProMotion 2+, you must use `title_image` or `title_view` instead."
          return raise StandardError
        end
        @title = t if t
        @title_type = :text if t
        @title ||= self.to_s
      end

      def title_type
        @title_type || :text
      end

      def title_image(t)
        @title = t.is_a?(UIImage) ? t : UIImage.imageNamed(t)
        @title_type = :image
      end

      def title_view(t)
        @title = t
        @title_type = :view
      end

      def status_bar(style=nil, args={})
        if NSBundle.mainBundle.objectForInfoDictionaryKey('UIViewControllerBasedStatusBarAppearance').nil?
          PM.logger.warn("status_bar will have no effect unless you set 'UIViewControllerBasedStatusBarAppearance' to false in your info.plist")
        end
        @status_bar_style = style
        @status_bar_animation = args[:animation] if args[:animation]
      end

      def status_bar_type
        @status_bar_style || :default
      end

      def status_bar_animation
        @status_bar_animation || UIStatusBarAnimationSlide
      end

      def nav_bar_button(side, args={})
        @nav_bar_button_args = args
        @nav_bar_button_args[:side] = side
      end

      def get_nav_bar_button
        @nav_bar_button_args
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
      base.extend(TabClassMethods) # TODO: Is there a better way?
    end
  end
end

# ===========================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/screen/screen.rb
# ===========================================================
module ProMotion
  class Screen < ViewController
    # You can inherit a screen from any UIViewController if you include the ScreenModule
    # Just make sure to implement the Obj-C methods in cocoatouch/view_controller.rb.
    include ProMotion::ScreenModule
  end
end

# ==========================================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/table/extensions/refreshable.rb
# ==========================================================================
module ProMotion
  module Table
    module Refreshable

      def make_refreshable(params={})
        pull_message = params[:pull_message] || "Pull to refresh"
        @refreshing = params[:refreshing] || "Refreshing data..."
        @updated_format = params[:updated_format] || "Last updated at %s"
        @updated_time_format = params[:updated_time_format] || "%l:%M %p"
        @refreshable_callback = params[:callback] || :on_refresh

        @refresh_control = UIRefreshControl.alloc.init
        @refresh_control.attributedTitle = NSAttributedString.alloc.initWithString(pull_message)
        @refresh_control.addTarget(self, action:'refreshView:', forControlEvents:UIControlEventValueChanged)
        self.refreshControl = @refresh_control
      end

      def start_refreshing
        return unless @refresh_control

        @refresh_control.beginRefreshing

        # Scrolls the table down to show the refresh control when invoked programatically
        tableView.setContentOffset(CGPointMake(0, tableView.contentOffset.y-@refresh_control.frame.size.height), animated:true) if tableView.contentOffset.y > -65.0
      end
      alias :begin_refreshing :start_refreshing

      def end_refreshing
        return unless @refresh_control

        @refresh_control.attributedTitle = NSAttributedString.alloc.initWithString(sprintf(@updated_format, Time.now.strftime(@updated_time_format)))
        @refresh_control.endRefreshing
      end
      alias :stop_refreshing :end_refreshing

      ######### iOS methods, headless camel case #######

      # UIRefreshControl Delegates
      def refreshView(refresh)
        refresh.attributedTitle = NSAttributedString.alloc.initWithString(@refreshing)
        if @refreshable_callback && self.respond_to?(@refreshable_callback)
          self.send(@refreshable_callback)
        else
          PM.logger.warn "You must implement the '#{@refreshable_callback}' method in your TableScreen."
        end
      end
    end
  end
end

# ========================================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/table/extensions/indexable.rb
# ========================================================================
module ProMotion
  module Table
    module Indexable
      def table_data_index
        return nil if self.promotion_table_data.filtered || !self.class.get_indexable

        index = self.promotion_table_data.sections.collect{ |section| (section[:title] || " ")[0] } || []
        index.unshift("{search}") if self.class.get_searchable
        index
      end
    end
  end
end

# =========================================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/table/extensions/searchable.rb
# =========================================================================
module ProMotion
  module Table
    module Searchable

      def make_searchable(params={})
        params = set_searchable_param_defaults(params)

        search_bar = create_search_bar(params)

        if params[:search_bar] && params[:search_bar][:placeholder]
          search_bar.placeholder = params[:search_bar][:placeholder]
        end

        @table_search_display_controller = UISearchDisplayController.alloc.initWithSearchBar(search_bar, contentsController: params[:content_controller])
        @table_search_display_controller.delegate = params[:delegate]
        @table_search_display_controller.searchResultsDataSource = params[:data_source]
        @table_search_display_controller.searchResultsDelegate = params[:search_results_delegate]

        self.tableView.tableHeaderView = search_bar
      end
      alias :makeSearchable :make_searchable

      def set_searchable_param_defaults(params)
        params[:content_controller] ||= params[:contentController]
        params[:data_source] ||= params[:searchResultsDataSource]
        params[:search_results_delegate] ||= params[:searchResultsDelegate]

        params[:frame] ||= CGRectMake(0, 0, 320, 44) # TODO: Don't hardcode this...
        params[:content_controller] ||= self
        params[:delegate] ||= self
        params[:data_source] ||= self
        params[:search_results_delegate] ||= self
        params
      end

      def create_search_bar(params)
        search_bar = UISearchBar.alloc.initWithFrame(params[:frame])
        search_bar.autoresizingMask = UIViewAutoresizingFlexibleWidth
        search_bar
      end

      ######### iOS methods, headless camel case #######

      def searchDisplayController(controller, shouldReloadTableForSearchString:search_string)
        self.promotion_table_data.search(search_string)
        true
      end

      def searchDisplayControllerWillEndSearch(controller)
        self.promotion_table_data.stop_searching
        self.table_view.setScrollEnabled true
        self.table_view.reloadData
        @table_search_display_controller.delegate.will_end_search if @table_search_display_controller.delegate.respond_to? "will_end_search"
      end

      def searchDisplayControllerWillBeginSearch(controller)
        self.table_view.setScrollEnabled false
        @table_search_display_controller.delegate.will_begin_search if @table_search_display_controller.delegate.respond_to? "will_begin_search"
      end

      def searchDisplayController(controller, didLoadSearchResultsTableView: tableView)
        tableView.rowHeight = self.table_view.rowHeight
      end
    end
  end
end

# ============================================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/table/extensions/longpressable.rb
# ============================================================================
module ProMotion
  module Table
    module Longpressable

      def make_longpressable(params={})
        params = {
          min_duration: 1.0
        }.merge(params)

        long_press_gesture = UILongPressGestureRecognizer.alloc.initWithTarget(self, action:"on_long_press:")
        long_press_gesture.minimumPressDuration = params[:min_duration]
        long_press_gesture.delegate = self
        self.table_view.addGestureRecognizer(long_press_gesture)
      end

      def on_long_press(gesture)
        return unless gesture.state == UIGestureRecognizerStateBegan
        gesture_point = gesture.locationInView(pressed_table_view)
        index_path = pressed_table_view.indexPathForRowAtPoint(gesture_point)
        return unless index_path
        data_cell = self.promotion_table_data.cell(index_path: index_path)
        return unless data_cell
        trigger_action(data_cell[:long_press_action], data_cell[:arguments], index_path) if data_cell[:long_press_action]
      end

      private

      def pressed_table_view
        searching? ? @table_search_display_controller.searchResultsTableView : table_view
      end

    end
  end
end

# ===============================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/table/table_utils.rb
# ===============================================================
module ProMotion
  module Table
    module Utils
      def index_path_to_section_index(params)
        if params.is_a?(Hash) && params[:index_path]
          params[:section] = params[:index_path].section
          params[:index] = params[:index_path].row
        end
        params
      end

      # Determines if all members of an array are a certain class
      def array_all_members_of?(arr, klass)
        arr.select{ |e| e.is_a?(klass) }.length == arr.length
      end
    end
  end
end

# =================================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/table/grouped_table.rb
# =================================================================
module ProMotion
  module GroupedTable
    module GroupedTableClassMethods
      def table_style
        UITableViewStyleGrouped
      end
    end
    def self.included(base)
      base.extend(GroupedTableClassMethods)
    end
  end
end

# ===================================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/table/data/table_data.rb
# ===================================================================
module ProMotion
  class TableData
    include ProMotion::Table::Utils

    attr_accessor :data, :filtered_data, :search_string, :original_search_string, :filtered, :table_view, :search_params

    def initialize(data, table_view, search_action = nil)
      @search_action ||= search_action
      self.data = data
      self.table_view = WeakRef.new(table_view)
    end

    def section(index)
      sections.at(index) || { cells: [] }
    end

    def sections
      self.filtered ? self.filtered_data : self.data
    end

    def section_length(index)
      section(index)[:cells].length
    end

    def cell(params={})
      params = index_path_to_section_index(params)
      table_section = params[:unfiltered] ? self.data[params[:section]] : self.section(params[:section])
      c = table_section[:cells].at(params[:index].to_i)
      set_data_cell_defaults c
    end

    def delete_cell(params={})
      params = index_path_to_section_index(params)
      table_section = self.section(params[:section])
      table_section[:cells].delete_at(params[:index].to_i)
    end

    def move_cell(from, to)
      section(to.section)[:cells].insert(to.row, section(from.section)[:cells].delete_at(from.row))
    end

    def default_search(cell, search_string)
      cell[:searchable] != false && "#{cell[:title]}\n#{cell[:search_text]}".downcase.strip.include?(search_string.downcase.strip)
    end

    def search(search_string)
      start_searching(search_string)

      self.data.compact.each do |section|
        new_section = {}

        new_section[:cells] = section[:cells].map do |cell|
          if @search_action
            @search_action.call(cell, search_string)
          else
            self.default_search(cell, search_string)
          end ? cell : nil
        end.compact

        if new_section[:cells] && new_section[:cells].length > 0
          new_section[:title] = section[:title]
          self.filtered_data << new_section
        end
      end

      self.filtered_data
    end

    def stop_searching
      self.filtered_data = []
      self.filtered = false
      self.search_string = false
      self.original_search_string = false
    end

    def set_data_cell_defaults(data_cell)
      data_cell[:cell_style] ||= begin
        data_cell[:subtitle] ? UITableViewCellStyleSubtitle : UITableViewCellStyleDefault
      end
      data_cell[:cell_class] ||= PM::TableViewCell
      data_cell[:cell_identifier] ||= build_cell_identifier(data_cell)
      data_cell[:properties] ||= data_cell[:style] || data_cell[:styles]

      data_cell[:accessory] = {
        view: data_cell[:accessory],
        value: data_cell[:accessory_value],
        action: data_cell[:accessory_action],
        arguments: data_cell[:accessory_arguments]
      } unless data_cell[:accessory].nil? || data_cell[:accessory].is_a?(Hash)

      data_cell
    end

    def build_cell_identifier(data_cell)
      ident = "#{data_cell[:cell_class].to_s}"
      ident << "-#{data_cell[:stylename].to_s}" if data_cell[:stylename] # For Teacup
      ident << "-accessory" if data_cell[:accessory]
      ident << "-subtitle" if data_cell[:subtitle]
      ident << "-remoteimage" if data_cell[:remote_image]
      ident << "-image" if data_cell[:image]
      ident
    end

  private

    def start_searching(search_string)
      self.filtered_data = []
      self.filtered = true
      self.search_string = search_string.downcase.strip
      self.original_search_string = search_string
    end
  end
end

# =========================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/table/table.rb
# =========================================================
module ProMotion
  module Table
    include ProMotion::Styling
    include ProMotion::Table::Searchable
    include ProMotion::Table::Refreshable
    include ProMotion::Table::Indexable
    include ProMotion::Table::Longpressable
    include ProMotion::Table::Utils

    attr_reader :promotion_table_data

    def table_view
      self.view
    end

    def screen_setup
      check_table_data
      set_up_header_footer_views
      set_up_searchable
      set_up_refreshable
      set_up_longpressable
      set_up_row_height
    end

    def check_table_data
      PM.logger.error "Missing #table_data method in TableScreen #{self.class.to_s}." unless self.respond_to?(:table_data)
    end

    def promotion_table_data
      @promotion_table_data ||= TableData.new(table_data, table_view, setup_search_method)
    end

    def set_up_header_footer_views
      [:header, :footer].each do |hf_view|
        if self.respond_to?("table_#{hf_view}_view".to_sym)
          view = self.send("table_#{hf_view}_view")
          if view.is_a? UIView
            self.tableView.send(camelize("set_table_#{hf_view}_view:"), view)
          else
            PM.logger.warn "Table #{hf_view} view must be a UIView."
          end
        end
      end
    end

    def set_up_searchable
      if self.class.respond_to?(:get_searchable) && self.class.get_searchable
        self.make_searchable(content_controller: self, search_bar: self.class.get_searchable_params)
        if self.class.get_searchable_params[:hide_initially]
          self.tableView.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height)
        end
      end
    end

    def setup_search_method
      params = self.class.get_searchable_params
      if params.nil?
        return nil
      else
        @search_method || begin
          params = self.class.get_searchable_params
          @search_action = params[:with] || params[:find_by] || params[:search_by] || params[:filter_by]
          @search_action = method(@search_action) if @search_action.is_a?(Symbol) || @search_action.is_a?(String)
          @search_action
        end
      end
    end

    def set_up_refreshable
      if self.class.respond_to?(:get_refreshable) && self.class.get_refreshable
        if defined?(UIRefreshControl)
          self.make_refreshable(self.class.get_refreshable_params)
        else
          PM.logger.warn "To use the refresh control on < iOS 6, you need to include the CocoaPod 'CKRefreshControl'."
        end
      end
    end

    def set_up_longpressable
      if self.class.respond_to?(:get_longpressable) && self.class.get_longpressable
        self.make_longpressable(self.class.get_longpressable_params)
      end
    end

    def set_up_row_height
      if self.class.respond_to?(:get_row_height) && params = self.class.get_row_height
        self.view.rowHeight = params[:height]
        self.view.estimatedRowHeight = params[:estimated]
      end
    end

    def searching?
      self.promotion_table_data.filtered
    end

    def original_search_string
      self.promotion_table_data.original_search_string
    end

    def search_string
      self.promotion_table_data.search_string
    end

    def update_table_view_data(data, args = {})
      self.promotion_table_data.data = data
      if args[:index_paths]
        args[:animation] ||= UITableViewRowAnimationNone

        table_view.beginUpdates
        table_view.reloadRowsAtIndexPaths(Array(args[:index_paths]), withRowAnimation: args[:animation])
        table_view.endUpdates
      else
        table_view.reloadData
      end
      @table_search_display_controller.searchResultsTableView.reloadData if searching?
    end

    def trigger_action(action, arguments, index_path)
      return PM.logger.info "Action not implemented: #{action.to_s}" unless self.respond_to?(action)
      case self.method(action).arity
      when 0 then self.send(action) # Just call the method
      when 2 then self.send(action, arguments, index_path) # Send arguments and index path
      else self.send(action, arguments) # Send arguments
      end
    end

    def accessory_toggled_switch(switch)
      table_cell = closest_parent(UITableViewCell, switch)
      index_path = closest_parent(UITableView, table_cell).indexPathForCell(table_cell)

      if index_path
        data_cell = promotion_table_data.cell(section: index_path.section, index: index_path.row)
        data_cell[:accessory][:arguments][:value] = switch.isOn if data_cell[:accessory][:arguments].is_a?(Hash)
        trigger_action(data_cell[:accessory][:action], data_cell[:accessory][:arguments], index_path) if data_cell[:accessory][:action]
      end
    end

    def delete_row(index_paths, animation = nil)
      deletable_index_paths = []
      Array(index_paths).each do |index_path|
        delete_cell = false
        delete_cell = send(:on_cell_deleted, self.promotion_table_data.cell(index_path: index_path)) if self.respond_to?("on_cell_deleted:")
        unless delete_cell == false
          self.promotion_table_data.delete_cell(index_path: index_path)
          deletable_index_paths << index_path
        end
      end
      table_view.deleteRowsAtIndexPaths(deletable_index_paths, withRowAnimation: map_row_animation_symbol(animation)) if deletable_index_paths.length > 0
    end

    def create_table_cell(data_cell)
      new_cell = nil
      table_cell = table_view.dequeueReusableCellWithIdentifier(data_cell[:cell_identifier]) || begin
        new_cell = data_cell[:cell_class].alloc.initWithStyle(data_cell[:cell_style], reuseIdentifier:data_cell[:cell_identifier])
        new_cell.extend(PM::TableViewCellModule) unless new_cell.is_a?(PM::TableViewCellModule)
        new_cell.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin
        new_cell.clipsToBounds = true # fix for changed default in 7.1
        new_cell.send(:on_load) if new_cell.respond_to?(:on_load)
        new_cell
      end
      table_cell.setup(data_cell, self) if table_cell.respond_to?(:setup)
      table_cell.send(:on_reuse) if !new_cell && table_cell.respond_to?(:on_reuse)
      table_cell
    end

    def update_table_data(args = {})
      args = { index_paths: args } unless args.is_a?(Hash)

      self.update_table_view_data(self.table_data, args)
      self.promotion_table_data.search(search_string) if searching?
    end

    def toggle_edit_mode(animated = true)
      edit_mode({enabled: !editing?, animated: animated})
    end

    def edit_mode(args = {})
      args[:enabled] = false if args[:enabled].nil?
      args[:animated] = true if args[:animated].nil?

      setEditing(args[:enabled], animated:args[:animated])
    end

    def edit_mode?
      !!isEditing
    end

    ########## Cocoa touch methods #################
    def numberOfSectionsInTableView(_)
      self.promotion_table_data.sections.length
    end

    # Number of cells
    def tableView(_, numberOfRowsInSection: section)
      self.promotion_table_data.section_length(section)
    end

    def tableView(_, titleForHeaderInSection: section)
      section = promotion_table_data.section(section)
      section && section[:title]
    end

    # Set table_data_index if you want the right hand index column (jumplist)
    def sectionIndexTitlesForTableView(_)
      return if self.promotion_table_data.filtered
      return self.table_data_index if self.respond_to?(:table_data_index)
      nil
    end

    def tableView(_, cellForRowAtIndexPath: index_path)
      params = index_path_to_section_index(index_path: index_path)
      data_cell = self.promotion_table_data.cell(section: params[:section], index: params[:index])
      return UITableViewCell.alloc.init unless data_cell
      create_table_cell(data_cell)
    end

    def tableView(_, willDisplayCell: table_cell, forRowAtIndexPath: index_path)
      data_cell = self.promotion_table_data.cell(index_path: index_path)
      table_cell.send(:will_display) if table_cell.respond_to?(:will_display)
      table_cell.send(:restyle!) if table_cell.respond_to?(:restyle!) # Teacup compatibility
    end

    def tableView(_, heightForRowAtIndexPath: index_path)
      (self.promotion_table_data.cell(index_path: index_path)[:height] || tableView.rowHeight).to_f
    end

    def tableView(table_view, didSelectRowAtIndexPath: index_path)
      data_cell = self.promotion_table_data.cell(index_path: index_path)
      table_view.deselectRowAtIndexPath(index_path, animated: true) unless data_cell[:keep_selection] == true
      trigger_action(data_cell[:action], data_cell[:arguments], index_path) if data_cell[:action]
    end

    def tableView(_, editingStyleForRowAtIndexPath: index_path)
      data_cell = self.promotion_table_data.cell(index_path: index_path, unfiltered: true)
      map_cell_editing_style(data_cell[:editing_style])
    end

    def tableView(_, commitEditingStyle: editing_style, forRowAtIndexPath: index_path)
      if editing_style == UITableViewCellEditingStyleDelete
        delete_row(index_path)
      end
    end

    def tableView(_, canMoveRowAtIndexPath:index_path)
      data_cell = self.promotion_table_data.cell(index_path: index_path, unfiltered: true)

      if (!data_cell[:moveable].nil? || data_cell[:moveable].is_a?(Symbol)) && data_cell[:moveable] != false
        true
      else
        false
      end
    end

    def tableView(_, targetIndexPathForMoveFromRowAtIndexPath:source_index_path, toProposedIndexPath:proposed_destination_index_path)
      data_cell = self.promotion_table_data.cell(index_path: source_index_path, unfiltered: true)

      if data_cell[:moveable] == :section && source_index_path.section != proposed_destination_index_path.section
        source_index_path
      else
        proposed_destination_index_path
      end
    end

    def tableView(_, moveRowAtIndexPath:from_index_path, toIndexPath:to_index_path)
      self.promotion_table_data.move_cell(from_index_path, to_index_path)

      if self.respond_to?("on_cell_moved:")
        args = {
          paths: {
            from: from_index_path,
            to: to_index_path
          },
          cell: self.promotion_table_data.section(to_index_path.section)[:cells][to_index_path.row]
        }
        send(:on_cell_moved, args)
      else
        PM.logger.warn "Implement the on_cell_moved method in your PM::TableScreen to be notified when a user moves a cell."
      end
    end

    def tableView(table_view, sectionForSectionIndexTitle: title, atIndex: index)
      return index unless ["{search}", UITableViewIndexSearch].include?(self.table_data_index[0])

      if index == 0
        table_view.scrollRectToVisible(CGRectMake(0.0, 0.0, 1.0, 1.0), animated: false)
        NSNotFound
      else
        index - 1
      end
    end

    def deleteRowsAtIndexPaths(index_paths, withRowAnimation: animation)
      PM.logger.warn "ProMotion expects you to use 'delete_cell(index_paths, animation)'' instead of 'deleteRowsAtIndexPaths(index_paths, withRowAnimation:animation)'."
      delete_row(index_paths, animation)
    end

    # Section view methods
    def tableView(_, viewForHeaderInSection: index)
      section = promotion_table_data.section(index)
      view = section[:title_view]
      view = section[:title_view].new if section[:title_view].respond_to?(:new)
      view.title = section[:title] if view.respond_to?(:title=)
      view
    end

    def tableView(_, heightForHeaderInSection: index)
      section = promotion_table_data.section(index)
      if section[:title_view] || section[:title].to_s.length > 0
        section[:title_view_height] || tableView.sectionHeaderHeight
      else
        0.0
      end
    end

    def tableView(_, willDisplayHeaderView:view, forSection:section)
      action = :will_display_header
      if respond_to?(action)
        case self.method(action).arity
        when 0 then self.send(action)
        when 2 then self.send(action, view, section)
        else self.send(action, view)
        end
      end
    end

    protected

    def map_cell_editing_style(symbol)
      {
        none:   UITableViewCellEditingStyleNone,
        delete: UITableViewCellEditingStyleDelete,
        insert: UITableViewCellEditingStyleInsert
      }[symbol] || symbol || UITableViewCellEditingStyleNone
    end

    def map_row_animation_symbol(symbol)
      symbol ||= UITableViewRowAnimationAutomatic
      {
        fade:       UITableViewRowAnimationFade,
        right:      UITableViewRowAnimationRight,
        left:       UITableViewRowAnimationLeft,
        top:        UITableViewRowAnimationTop,
        bottom:     UITableViewRowAnimationBottom,
        none:       UITableViewRowAnimationNone,
        middle:     UITableViewRowAnimationMiddle,
        automatic:  UITableViewRowAnimationAutomatic
      }[symbol] || symbol || UITableViewRowAnimationAutomatic
    end

    module TableClassMethods
      def table_style
        UITableViewStylePlain
      end

      def row_height(height, args={})
        if height == :auto
          if UIDevice.currentDevice.systemVersion.to_f < 8.0
            height = args[:estimated] || 44.0
            PM.logger.warn "Using `row_height :auto` is not supported in iOS 7 apps. Setting to #{height}."
          else
            height = UITableViewAutomaticDimension
          end
        end
        args[:estimated] ||= height unless height == UITableViewAutomaticDimension
        @row_height = { height: height, estimated: args[:estimated] || 44.0 }
      end

      def get_row_height
        @row_height ||= nil
      end

      # Searchable
      def searchable(params={})
        @searchable_params = params
        @searchable = true
      end

      def get_searchable_params
        @searchable_params ||= nil
      end

      def get_searchable
        @searchable ||= false
      end

      # Refreshable
      def refreshable(params = {})
        @refreshable_params = params
        @refreshable = true
      end

      def get_refreshable
        @refreshable ||= false
      end

      def get_refreshable_params
        @refreshable_params ||= nil
      end

      # Indexable
      def indexable(params = {})
        @indexable_params = params
        @indexable = true
      end

      def get_indexable
        @indexable ||= false
      end

      def get_indexable_params
        @indexable_params ||= nil
      end

      # Longpressable
      def longpressable(params = {})
        @longpressable_params = params
        @longpressable = true
      end

      def get_longpressable
        @longpressable ||= false
      end

      def get_longpressable_params
        @longpressable_params ||= nil
      end
    end

    def self.included(base)
      base.extend(TableClassMethods)
    end

  end
end

# ===================================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/web/web_screen_module.rb
# ===================================================================
module ProMotion
  module WebScreenModule

    attr_accessor :webview, :external_links, :detector_types, :scale_to_fit

    def screen_setup
      check_content_data
      self.external_links ||= false
      self.scale_to_fit ||= false
      self.detector_types ||= :none

      web_view_setup
      set_initial_content
    end

    def on_init
      # TODO: Remove in 3.0
    end

    def web_view_setup
      self.webview ||= add UIWebView.new, {
        frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height),
        delegate: self,
        data_detector_types: data_detector_types
      }
      self.webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
      self.webview.scalesPageToFit = self.scale_to_fit
      self.webview.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
    end

    def web
      self.webview
    end

    def set_initial_content
      return unless self.respond_to?(:content) && self.content
      self.content.is_a?(NSURL) ? open_url(self.content) : set_content(self.content)
    end

    def set_content(content)
      content_path = File.join(NSBundle.mainBundle.resourcePath, content)

      if File.exists? content_path
        content_string = File.read content_path
        content_base_url = NSURL.fileURLWithPath NSBundle.mainBundle.resourcePath

        self.web.loadHTMLString(convert_retina_images(content_string), baseURL:content_base_url)
      else
        # We assume the user wants to load an arbitrary string into the web view
        self.web.loadHTMLString(content, baseURL:nil)
      end
    end

    def open_url(url)
      request = NSURLRequest.requestWithURL(
        url.is_a?(NSURL) ? url : NSURL.URLWithString(url)
      )
      web.loadRequest request
    end

    def convert_retina_images(content)
      #Convert images over to retina if the images exist.
      if UIScreen.mainScreen.bounds.respondsToSelector('displayLinkWithTarget:selector:') && UIScreen.mainScreen.bounds.scale == 2.0 # Thanks BubbleWrap! https://github.com/rubymotion/BubbleWrap/blob/master/motion/core/device/ios/screen.rb#L9
        content.gsub!(/src=['"](.*?)\.(jpg|gif|png)['"]/) do |img|
          if File.exists?(File.join(NSBundle.mainBundle.resourcePath, "#{$1}@2x.#{$2}"))
            # Create a UIImage to get the width and height of hte @2x image
            tmp_image = UIImage.imageNamed("/#{$1}@2x.#{$2}")
            new_width = tmp_image.size.width / 2
            new_height = tmp_image.size.height / 2

            img = "src=\"#{$1}@2x.#{$2}\" width=\"#{new_width}\" height=\"#{new_height}\""
          end
        end
      end
      content
    end

    def check_content_data
      PM.logger.error "Missing #content method in WebScreen #{self.class.to_s}." unless self.respond_to?(:content)
    end

    def html
      evaluate("document.documentElement.outerHTML")
    end

    def evaluate(js)
      self.webview.stringByEvaluatingJavaScriptFromString(js)
    end

    def current_url
      evaluate('document.URL')
    end

    # Navigation
    def can_go_back; web.canGoBack; end
    def can_go_forward; web.canGoForward; end
    def back; web.goBack if can_go_back; end
    def forward; web.goForward if can_go_forward; end
    def refresh; web.reload; end
    def stop; web.stopLoading; end
    alias :reload :refresh

    def open_in_chrome(in_request)
      # Add pod 'OpenInChrome' to your Rakefile if you want links to open in Google Chrome for users.
      # This will fall back to Safari if the user doesn't have Chrome installed.
      chrome_controller = OpenInChromeController.sharedInstance
      return open_in_safari(in_request) unless chrome_controller.isChromeInstalled
      chrome_controller.openInChrome(in_request.URL)
    end

    def open_in_safari(in_request)
      # Open UIWebView delegate links in Safari.
      UIApplication.sharedApplication.openURL(in_request.URL)
    end

    # UIWebViewDelegate Methods - Camelcase
    def webView(in_web, shouldStartLoadWithRequest:in_request, navigationType:in_type)
      if %w(http https).include?(in_request.URL.scheme)
        if self.external_links == true && in_type == UIWebViewNavigationTypeLinkClicked
          if defined?(OpenInChromeController)
            open_in_chrome in_request
          else
            open_in_safari in_request
          end
          return false # don't allow the web view to load the link.
        end
      end

      load_request_enable = true #return true on default for local file loading.
      load_request_enable = !!on_request(in_request, in_type) if self.respond_to?(:on_request)
      load_request_enable
    end

    def webViewDidStartLoad(webView)
      load_started if self.respond_to?(:load_started)
    end

    def webViewDidFinishLoad(webView)
      load_finished if self.respond_to?(:load_finished)
    end

    def webView(webView, didFailLoadWithError:error)
      load_failed(error) if self.respond_to?("load_failed:")
    end

    protected

    def data_detector_types
      Array(self.detector_types).reduce(UIDataDetectorTypeNone) do |detectors, dt|
        detectors | map_detector_symbol(dt)
      end
    end

    def map_detector_symbol(symbol)
      {
        phone:    UIDataDetectorTypePhoneNumber,
        link:     UIDataDetectorTypeLink,
        address:  UIDataDetectorTypeAddress,
        event:    UIDataDetectorTypeCalendarEvent,
        all:      UIDataDetectorTypeAll
      }[symbol] || UIDataDetectorTypeNone
    end

  end
end

# ========================================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/table/grouped_table_screen.rb
# ========================================================================
module ProMotion
  class GroupedTableScreen < TableViewController
    include ProMotion::ScreenModule
    include ProMotion::Table
    include ProMotion::Table::Utils # Workaround until https://hipbyte.freshdesk.com/support/tickets/2086 is fixed.
    include ProMotion::GroupedTable
  end
end

# ================================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/table/table_screen.rb
# ================================================================
module ProMotion
  class TableScreen < TableViewController
    include ProMotion::ScreenModule
    include ProMotion::Table
  end
end

# ============================================================
# /Users/jh/Code/iOS/ProMotion/lib/ProMotion/web/web_screen.rb
# ============================================================
module ProMotion
  class WebScreen < ViewController
    include ProMotion::ScreenModule
    include ProMotion::WebScreenModule
  end
end

# ==================================
# ./app/test_screens/basic_screen.rb
# ==================================
class BasicScreen < PM::Screen
  title "Basic"

  attr_reader :animation_ts

  def will_appear
    @will_appear_ts = NSDate.date
  end

  def on_appear
    @on_appear_ts = NSDate.date
    @animation_ts = @on_appear_ts - @will_appear_ts
  end

end

# =======================================
# ./app/test_screens/functional_screen.rb
# =======================================
class FunctionalScreen < PM::Screen
  attr_accessor :button_was_triggered
  attr_accessor :button2_was_triggered
  attr_accessor :on_back_fired

  title "Functional"

  def will_appear
    self.button_was_triggered = false
    self.button2_was_triggered = false
    add UILabel.alloc.initWithFrame([[ 10, 10 ], [ 300, 40 ]]), { text: "Label Here" }
  end

  def triggered_button
    self.button_was_triggered = true
  end

  def triggered_button2
    self.button2_was_triggered = true
  end

  def on_back
    @on_back_fired = true
  end
end

# ===================================
# ./app/test_screens/detail_screen.rb
# ===================================
class DetailScreen < PM::Screen
  title "Detail"

  nav_bar_button :right, title: "More", style: :plain, action: :back
end

# ========================================
# ./app/test_screens/image_title_screen.rb
# ========================================
class ImageTitleScreen < FunctionalScreen
  title_image 'test.png'
end

# =============================================
# ./app/test_screens/image_view_title_screen.rb
# =============================================
class ImageViewTitleScreen < FunctionalScreen
  title_view UIImageView.alloc.initWithImage(UIImage.imageNamed('test.png'))
end

# =================================
# ./app/test_screens/home_screen.rb
# =================================
class HomeScreen < ProMotion::Screen

  title "Home"

  def on_load
    set_nav_bar_button :left, title: "Save", action: :save_something, type: :done
    set_nav_bar_button :right, image: UIImage.imageNamed("list.png"), action: :return_to_some_other_screen, type: :plain
  end

  def on_return(args={})
  end

  def subview_styles
    {
      background_color: UIColor.greenColor
    }
  end

end

# ===========================================
# ./app/test_screens/navigation_controller.rb
# ===========================================
class CustomNavigationController < PM::NavigationController
  
end

# =======================================
# ./app/test_screens/navigation_screen.rb
# =======================================
class NavigationScreen < PM::Screen
  attr_reader :on_back_fired

  def on_back
    @on_back_fired = true
  end

end

# =======================================
# ./app/test_screens/test_table_screen.rb
# =======================================
class TestTableScreen < ProMotion::TableScreen
  attr_accessor :tap_counter, :cell_was_deleted, :got_index_path, :cell_was_moved, :got_will_display_header

  title 'Test title'
  tab_bar_item title: 'Test tab title', item: 'test'
  row_height :auto, estimated: 97

  def on_load
    self.tap_counter = 0
    set_attributes self.view, { backgroundView: nil, backgroundColor: UIColor.whiteColor }
    set_nav_bar_button :right, title: UIImage.imageNamed("list.png"), action: :return_to_some_other_screen, type: UIBarButtonItemStylePlain
  end

  def table_data
    @data ||= [{
      title: "Your Account",
      cells: [
        { title: "Increment", action: :increment_counter_by, arguments: {number: 3} },
        { title: "Add New Row", action: :add_tableview_row },
        { title: "Delete the row below", action: :delete_cell, arguments: {section: 0, row:3} },
        { title: "Just another deletable blank row", editing_style: :delete },
        { title: "A non-deletable blank row", editing_style: :delete },
        { title: "Delete the row below with an animation", action: :delete_cell, arguments: {animated: true, section: 0, row:5 } },
        { title: "Just another blank row" }
      ]
    }, {
      title: "App Stuff",
      cells: [
        { title: "Increment One", action: :increment_counter },
        { title: "Feedback", cell_identifier: "ImagedCell", remote_image: { url: "http://placekitten.com/100/100", placeholder: "some-local-image", size: 50, radius: 15 } }
      ]
    }, {
      title: "Image Tests",
      cells: [
        { title: "Image Test 1", cell_identifier: "ImagedCell", image: {image: UIImage.imageNamed("list.png"), radius: 10} },
        { title: "Image Test 2", cell_identifier: "ImagedCell", image: {image: "list.png"} },
        { title: "Image Test 3", cell_identifier: "ImagedCell", cell_identifier: "ImagedCell", image: UIImage.imageNamed("list.png") },
        { title: "Image Test 4", image: "list.png" },
      ]
    }, {
      title: "Cell Accessory Tests",
      cells: [{
        title: "Switch With Action",
        accessory: {
          view: :switch,
          action: :increment_counter,
          accessibility_label: "switch_1"
        },
      }, {
        title: "Switch With Action And Parameters",
        accessory: {
          view: :switch,
          action: :increment_counter_by,
          arguments: { number: 3 },
          accessibility_label: "switch_2"
        },
      }, {
        title: "Switch With Cell Tap, Switch Action And Parameters",
        accessory:{
          view: :switch,
          action: :increment_counter_by,
          arguments: { number: 3 },
          accessibility_label: "switch_3"
        },
        action: :increment_counter_by,
        arguments: { number: 10 }
      }]
    },{
      title: "Moveable Tests",
      cells: [{
        title: 'Cell 1',
        moveable: :section
      },{
        title: 'Cell 2',
        moveable: true
      },{
        title: 'Cell 3'
      },{
        title: 'Cell 4',
        moveable: true
      },{
        title: 'Cell 5',
        moveable: false
      }]
    }]
  end

  def edit_profile(args={})
    args[:id]
  end

  def add_tableview_row(args={})
    @data[0][:cells] << {
      title: "Dynamically Added"
    }
    update_table_data
  end

  def delete_cell(args={})
    if args[:animated]
      delete_row(NSIndexPath.indexPathForRow(args[:row], inSection:args[:section]))
    else
      @data[args[:section]][:cells].delete_at args[:row]
      update_table_data
    end
  end

  def on_cell_deleted(cell)
    if cell[:title] == "A non-deletable blank row"
      false
    else
      self.cell_was_deleted = true
    end
  end

  def tests_index_path(args, index_path)
    @got_index_path = index_path
  end

  def increment_counter
    self.tap_counter = self.tap_counter + 1
  end

  def increment_counter_by(args={})
    self.tap_counter = self.tap_counter + args[:number]
  end

  def custom_accessory_view
    set_attributes UIView.new, background_color: UIColor.orangeColor
  end

  def scroll_to_bottom
    if table_view.contentSize.height > table_view.frame.size.height
      offset = CGPointMake(0, table_view.contentSize.height - table_view.frame.size.height)
      table_view.setContentOffset(offset, animated:false)
    end
  end

  def will_display_header(view, section)
    @got_will_display_header = {view: view, section: section}
  end

  def table_header_view
    UIImageView.alloc.initWithImage(UIImage.imageNamed('test'))
  end

  def table_footer_view
    UIView.alloc.initWithFrame(CGRectZero)
  end

  def on_cell_moved(args={})
    self.cell_was_moved = args
  end

end

# ======================================
# ./app/test_screens/load_view_screen.rb
# ======================================
class MyView < UIView; end

class LoadViewScreen < PM::Screen
  def load_view
    self.view = MyView.new
  end

  def on_load
    self.view.backgroundColor = UIColor.redColor
  end
end

class MyTableView < UITableView; end

class LoadViewTableScreen < PM::Screen
  def load_view
    self.view = MyTableView.new
  end

  def on_load
    self.view.backgroundColor = UIColor.greenColor
  end

  def table_data
    []
  end
end

# ===================================
# ./app/test_screens/master_screen.rb
# ===================================
class MasterScreen < PM::Screen
  title "Master"
end

# ================================
# ./app/test_screens/tab_screen.rb
# ================================
class TabScreen < PM::Screen
  title "Tab"
  tab_bar_item title: "Tab Item", item: "list", image_insets: [5,5,5,5]
end

# ============================================
# ./app/test_screens/table_screen_indexable.rb
# ============================================
class TableScreenIndexable < PM::TableScreen
  indexable

  def table_data
    %w{ Apple Google Microsoft Oracle Sun UNIX }.map do |group_name|
      {
        title: "#{group_name} Group",
        cells: [{ title: "Single cell for group #{group_name}" }]
      }
    end
  end

end

class TableScreenIndexableNil < TableScreenIndexable
  indexable

  def table_data
    super.push({title: nil, cells: [{ title: "Single cell for group nil" }]})
  end
end

class TableScreenIndexableSearchable < TableScreenIndexable
  indexable
  searchable
end

# ====================================
# ./app/test_screens/present_screen.rb
# ====================================
class PresentScreen < PM::Screen
  attr_accessor :will_present_fired, :on_present_fired, :will_dismiss_fired, :on_dismiss_fired

  def will_present
    self.will_present_fired = true
  end

  def on_present
    self.on_present_fired = true
  end

  def will_dismiss
    self.will_dismiss_fired = true
  end

  def on_dismiss
    self.on_dismiss_fired = true
  end

  def reset
    self.will_present_fired = false
    self.on_present_fired = false
    self.will_dismiss_fired = false
    self.on_dismiss_fired = false
  end
end

# ===================================================
# ./app/test_screens/screen_module_view_controller.rb
# ===================================================
class ScreenModuleViewController < UIViewController
  include PM::ScreenModule
  title 'Test Title'

  def self.new(args = {})
    s = self.alloc.initWithNibName(nil, bundle:nil)
    s.screen_init(args) if s.respond_to?(:screen_init)
    s
  end

  def viewDidLoad
    super
    self.view_did_load if self.respond_to?(:view_did_load)
  end

  def viewWillAppear(animated)
    super
    self.view_will_appear(animated) if self.respond_to?("view_will_appear:")
  end

  def viewDidAppear(animated)
    super
    self.view_did_appear(animated) if self.respond_to?("view_did_appear:")
  end

  def viewWillDisappear(animated)
    self.view_will_disappear(animated) if self.respond_to?("view_will_disappear:")
    super
  end

  def viewDidDisappear(animated)
    if self.respond_to?("view_did_disappear:")
      self.view_did_disappear(animated)
    end
    super
  end

  def shouldAutorotateToInterfaceOrientation(orientation)
    self.should_rotate(orientation)
  end

  def shouldAutorotate
    self.should_autorotate
  end

  def willRotateToInterfaceOrientation(orientation, duration:duration)
    self.will_rotate(orientation, duration)
  end

  def didRotateFromInterfaceOrientation(orientation)
    self.on_rotate
  end
end

# =============================================
# ./app/test_screens/table_screen_searchable.rb
# =============================================
class TableScreenSearchable < TestTableScreen

  searchable

  attr_accessor :will_end_search_called, :will_begin_search_called

  STATES = [
    "Alabama",
    "Alaska",
    "Arizona",
    "Arkansas",
    "California",
    "Colorado",
    "Connecticut",
    "Delaware",
    "Florida",
    "Georgia",
    "Hawaii",
    "Idaho",
    "Illinois",
    "Indiana",
    "Iowa",
    "Kansas",
    "Kentucky",
    "Louisiana",
    "Maine",
    "Maryland",
    "Massachusetts",
    "Michigan",
    "Minnesota",
    "Mississippi",
    "Missouri",
    "Montana",
    "Nebraska",
    "Nevada",
    "New Hampshire",
    "New Jersey",
    "New Mexico",
    "New York",
    "North Carolina",
    "North Dakota",
    "Ohio",
    "Oklahoma",
    "Oregon",
    "Pennsylvania",
    "Rhode Island",
    "South Carolina",
    "South Dakota",
    "Tennessee",
    "Texas",
    "Utah",
    "Vermont",
    "Virginia",
    "Washington",
    "West Virginia",
    "Wisconsin",
    "Wyoming"
  ].freeze

  def on_load
    super
    @subtitle ||= 0
  end

  def table_data
    @search_table_data = [{
      cells: state_cells
    }]
  end

  def build_cell(title)
    {
      title: title,
      subtitle: @subtitle.to_s,
      action: :update_subtitle
    }
  end

  def update_subtitle
    @subtitle = @subtitle + 1
    update_table_data
  end

  def will_begin_search
    self.will_begin_search_called = true
  end

  def will_end_search
    self.will_end_search_called = true
  end

  def state_cells
    STATES.map{ |state| build_cell(state) }
  end

end

class TableScreenStabbySearchable < TableScreenSearchable
  searchable with: -> (cell, search_string) {
    result = true
    search_string.split(/\s+/).each {|term|
      result &&= cell[:properties][:searched_title].downcase.strip.include?(term.downcase.strip)
    }
    return result
  }

  def build_cell(title)
    {
      title: title,
      subtitle: @subtitle.to_s,
      action: :update_subtitle,
      properties: {
        searched_title: "#{title} - stabby"
      }
    }
  end
end

class TableScreenSymbolSearchable < TableScreenSearchable
  searchable with: :custom_search

  def custom_search(cell, search_string)
    result = true
    search_string.split(/\s+/).all? {|term|
      cell[:properties][:searched_title].downcase.strip.include?(term.downcase.strip)
    }
  end

  def build_cell(title)
    {
      title: title,
      subtitle: @subtitle.to_s,
      action: :update_subtitle,
      properties: {
        searched_title: "#{title} - symbol"
      }
    }
  end
end

# ===================================
# ./app/test_screens/test_delegate.rb
# ===================================
class TestDelegate < ProMotion::Delegate
  status_bar false

  attr_accessor :called_on_load, :called_will_load, :called_on_activate, :called_will_deactivate, :called_on_enter_background, :called_will_enter_foreground, :called_on_unload, :called_on_tab_selected
  def on_load(app, options)
    self.called_on_load = true
  end

  def will_load(application, launch_options)
    self.called_will_load = true
  end

  def on_activate
    self.called_on_activate = true
  end

  def will_deactivate
    self.called_will_deactivate = true
  end

  def on_enter_background
    self.called_on_enter_background = true
  end

  def will_enter_foreground
    self.called_will_enter_foreground = true
  end

  def on_unload
    self.called_on_unload = true
  end

  def on_tab_selected(vc)
    self.called_on_tab_selected = true
  end
end

# ================================================
# ./app/test_screens/table_screen_longpressable.rb
# ================================================
class TableScreenLongpressable < TestTableScreen
  longpressable
end

# ==============================================
# ./app/test_screens/table_screen_refreshable.rb
# ==============================================
class TableScreenRefreshable < TestTableScreen
  attr_accessor :on_refresh_called

  refreshable

  def on_refresh
    self.on_refresh_called = true
    end_refreshing
  end

end
# =====================================
# ./app/test_screens/test_web_screen.rb
# =====================================
class TestWebScreen < PM::WebScreen

  title "WebScreen Test"

  # accesor for wait_change method which is testing helper
  attr_accessor :is_load_started, :is_load_finished, :is_load_failed, :is_load_failed_error

  def on_init
    @on_init_available = true
  end

  def on_init_available?
    @on_init_available
  end

  def content
    nil
  end

  # implementation of PM::WebScreen's hook
  def load_started
    self.is_load_started = true
  end

  def load_finished
    self.is_load_finished = true
  end

  def load_failed(error)
    puts "Load Failed: #{error.localizedDescription}"
    puts error.localizedFailureReason
    self.is_load_failed = true
    self.is_load_failed_error = error
  end
end

# ==========================================
# ./app/test_screens/test_delegate_colors.rb
# ==========================================
class TestDelegateColored < TestDelegate
  status_bar false

  def on_load(app, options)
    open BasicScreen.new(nav_bar: true)
  end
end

class TestDelegateRed < TestDelegateColored
  tint_color UIColor.redColor
end

# Other colors

# class TestDelegateBlack < TestDelegateColored
#   tint_color UIColor.blackColor
# end

# ============================================
# ./app/test_screens/test_mini_table_screen.rb
# ============================================
class TestCell < PM::TableViewCell
  attr_accessor :on_reuse_fired

  def on_reuse
    self.on_reuse_fired = true
  end
end

class TestMiniTableScreen < ProMotion::TableScreen

  attr_accessor :tap_counter, :cell_was_deleted, :got_index_path

  def table_data
    [{
      cells: (0..20).map do |n|
        { title: "test#{n}", cell_class: TestCell, height: 200, cell_identifier: "test" }
      end
    }]
  end
end

# =======================================
# ./app/test_screens/view_title_screen.rb
# =======================================
class ViewTitleScreen < FunctionalScreen
  title_view UIView.alloc.init
end

# =====================================
# ./app/test_views/custom_title_view.rb
# =====================================
class CustomTitleView < UITableViewCell
  attr_accessor :title
end


# ==========================================
# ./app/test_screens/uiimage_title_screen.rb
# ==========================================
class UIImageTitleScreen < FunctionalScreen
  title_image UIImage.imageNamed('test.png')
end

# ==============================================
# ./app/test_screens/update_test_table_screen.rb
# ==============================================
class UpdateTestTableScreen < PM::TableScreen
  row_height 77

  def table_data; @table_data ||= []; end
  def on_load
    @table_data = [{cells: []}]
    update_table_data
  end

  def make_more_cells
    @table_data = [{cells: [{title: "Cell 1"},{title: "Cell 2"}]}]
  end

  def change_cells
    @table_data = [{cells: [{title: "Cell A"},{title: "Cell B"}]}]
  end

  def first_cell_title
    cell_title(0)
  end

  def second_cell_title
    cell_title(1)
  end

  def cell_title(index)
    ip = NSIndexPath.indexPathForRow(index, inSection:0)
    table_view.cellForRowAtIndexPath(ip).textLabel.text
  end
end

# =====================
# ./app/app_delegate.rb
# =====================
class AppDelegate < ProMotion::Delegate

  def on_load(app, options)
    open BasicScreen.new(nav_bar: true)
  end

end

# ====================================================================================
# /Users/jh/.gem/ruby/2.2.0/gems/motion-redgreen-0.1.0/lib/motion-redgreen/ansiterm.rb
# ====================================================================================
#return unless App.development?

module Term
  # The ANSIColor module can be used for namespacing and mixed into your own
  # classes.
  module ANSIColor
    # :stopdoc:
    ATTRIBUTES = [
      [ :clear        ,   0 ],
      [ :reset        ,   0 ],     # synonym for :clear
      [ :bold         ,   1 ],
      [ :dark         ,   2 ],
      [ :italic       ,   3 ],     # not widely implemented
      [ :underline    ,   4 ],
      [ :underscore   ,   4 ],     # synonym for :underline
      [ :blink        ,   5 ],
      [ :rapid_blink  ,   6 ],     # not widely implemented
      [ :negative     ,   7 ],     # no reverse because of String#reverse
      [ :concealed    ,   8 ],
      [ :strikethrough,   9 ],     # not widely implemented
      [ :black        ,  30 ],
      [ :red          ,  31 ],
      [ :green        ,  32 ],
      [ :yellow       ,  33 ],
      [ :blue         ,  34 ],
      [ :magenta      ,  35 ],
      [ :cyan         ,  36 ],
      [ :white        ,  37 ],
      [ :on_black     ,  40 ],
      [ :on_red       ,  41 ],
      [ :on_green     ,  42 ],
      [ :on_yellow    ,  43 ],
      [ :on_blue      ,  44 ],
      [ :on_magenta   ,  45 ],
      [ :on_cyan      ,  46 ],
      [ :on_white     ,  47 ],
    ]

    ATTRIBUTE_NAMES = ATTRIBUTES.transpose.first
    # :startdoc:

    # Returns true, if the coloring function of this module
    # is switched on, false otherwise.
    def self.coloring?
      @coloring
    end

    # Turns the coloring on or off globally, so you can easily do
    # this for example:
    #  Term::ANSIColor::coloring = STDOUT.isatty
    def self.coloring=(val)
      @coloring = val
    end
    self.coloring = true


      def clear(string = nil)
        result = ''
        result << "[0m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def reset(string = nil)
        result = ''
        result << "[0m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def bold(string = nil)
        result = ''
        result << "[1m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def dark(string = nil)
        result = ''
        result << "[2m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def italic(string = nil)
        result = ''
        result << "[3m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def underline(string = nil)
        result = ''
        result << "[4m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def underscore(string = nil)
        result = ''
        result << "[4m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def blink(string = nil)
        result = ''
        result << "[5m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def rapid_blink(string = nil)
        result = ''
        result << "[6m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def negative(string = nil)
        result = ''
        result << "[7m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def concealed(string = nil)
        result = ''
        result << "[8m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def strikethrough(string = nil)
        result = ''
        result << "[9m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def black(string = nil)
        result = ''
        result << "[30m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def red(string = nil)
        result = ''
        result << "[31m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def green(string = nil)
        result = ''
        result << "[32m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def yellow(string = nil)
        result = ''
        result << "[33m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def blue(string = nil)
        result = ''
        result << "[34m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def magenta(string = nil)
        result = ''
        result << "[35m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def cyan(string = nil)
        result = ''
        result << "[36m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def white(string = nil)
        result = ''
        result << "[37m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def on_black(string = nil)
        result = ''
        result << "[40m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def on_red(string = nil)
        result = ''
        result << "[41m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def on_green(string = nil)
        result = ''
        result << "[42m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def on_yellow(string = nil)
        result = ''
        result << "[43m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def on_blue(string = nil)
        result = ''
        result << "[44m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def on_magenta(string = nil)
        result = ''
        result << "[45m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def on_cyan(string = nil)
        result = ''
        result << "[46m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end


      def on_white(string = nil)
        result = ''
        result << "[47m" if Term::ANSIColor.coloring?
        if block_given?
          result << yield
        elsif string
          result << string
        elsif respond_to?(:to_str)
          result << self
        else
          return result #only switch on
        end
        result << "[0m" if Term::ANSIColor.coloring?
        result
      end

    # Regular expression that is used to scan for ANSI-sequences while
    # uncoloring strings.
    COLORED_REGEXP = /\e\[([34][0-7]|[0-9])m/

    # Returns an uncolored version of the string, that is all
    # ANSI-sequences are stripped from the string.
    def uncolored(string = nil) # :yields:
      if block_given?
        yield.gsub(COLORED_REGEXP, '')
      elsif string
        string.gsub(COLORED_REGEXP, '')
      elsif respond_to?(:to_str)
        gsub(COLORED_REGEXP, '')
      else
        ''
      end
    end

    module_function

    # Returns an array of all Term::ANSIColor attributes as symbols.
    def attributes
      ATTRIBUTE_NAMES
    end
    extend self
  end
end
# ==================================================================================
# /Users/jh/.gem/ruby/2.2.0/gems/motion-redgreen-0.1.0/lib/motion-redgreen/string.rb
# ==================================================================================
String.send :include, Term::ANSIColor
