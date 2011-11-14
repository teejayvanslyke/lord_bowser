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

    BROWSER_EXPRESSION = /^(\w+) ([\<\>\=]+) ([\d\.]+)$/.freeze

    def parse(expr)
      if expr.match(BROWSER_EXPRESSION)
        return { vendor: $~[1].intern, operator: $~[2].intern, version: $~[3].to_f }
      elsif expr.match(/^(\w+)$/)
        return { vendor: $~[1].intern }
      else
        return nil
      end
    end

    def is?(*args)
      args.select do |arg|
        data = parse(arg)
        if data.nil?
          false
        elsif [ :vendor, :operator, :version ].all? {|k| data.has_key?(k) }
          self.vendor == data[:vendor] && self.send(data[:operator], data[:version])
        elsif data.has_key?(:vendor)
          self.vendor == data[:vendor]
        end
      end.size > 0
    end

    def is_not?(*args)
      args.select do |arg|
        data = parse(arg)
        if data.nil?
          false
        elsif [ :vendor, :operator, :version ].all? {|k| data.has_key?(k) }
          self.vendor == data[:vendor] && self.send(data[:operator].intern, data[:version])
        elsif data.has_key?(:vendor)
          self.vendor == data[:vendor]
        end
      end.size == 0
    end

    def >=(version)
      @version >= version
    end

    def >(version)
      @version > version
    end

    def <=(version)
      @version <= version
    end

    def <(version)
      @version < version
    end

    attr_reader :vendor, :version, :user_agent

  end
end

