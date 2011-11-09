module LordBowser

  def browser
    @browser ||= Browser.new(request.env['HTTP_USER_AGENT'])
  end

  class Browser
    def initialize(user_agent)
      @user_agent = user_agent

      case @user_agent
      when /Firefox\/([\w\.]+)/
        @vendor = :firefox
        @version = $~[1].to_i
      when /Chrome\/([\w\.]+)/
        @vendor = :chrome
        @version = $~[1].to_i
      when /Opera\/([\w\.]+).*Version\/([\w\.]+)/
        @vendor = :opera
        @version = $~[2].to_i
      when /Opera\/([\w\.]+)/
        @vendor = :opera
        @version = $~[1].to_i
      when /MSIE ([\w\.]+)/
        @vendor = :ie
        @version = $~[1].to_i
      when /Version\/([\w\.]+) Safari/
        @vendor = :safari
        @version = $~[1].to_i
      end
    end

    def is?(*args)
      args.select do |arg|
        if arg.match(/^(\w+) ([\<\>\=]+) ([\d\.]+)$/)
          vendor  = $~[1].intern
          op      = $~[2]
          version = $~[3].to_f

          self.vendor == vendor && self.send(op.intern, version)
        elsif arg.match(/^(\w+)$/)
          vendor  = $~[1].intern
          self.vendor == vendor
        else
          false
        end
      end.size > 0
    end

    def >=(version)
      @version >= version
    end

    def >(version)
      @version > version
    end

    attr_reader :vendor, :version, :user_agent

  end
end

