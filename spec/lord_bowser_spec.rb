require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe LordBowser do

  def mock_controller(ua=nil)
    MockController.new(ua)
  end

  def self.when_user_agent(user_agent, &block)
    context user_agent do
      before { @controller = mock_controller(user_agent) }
      def browser
        @controller.browser
      end
      instance_eval &block
    end
  end

  when_user_agent "Mozilla/5.0 (X11; Linux i686; rv:6.0) Gecko/20100101 Firefox/6.0" do
    specify { browser.vendor.should == :firefox }
    specify { browser.version.should == 6 }
    specify { browser.is?('firefox >= 5').should be_true }
    specify { browser.is?('firefox >= 5', 'ie > 6').should be_true }
    specify { browser.is_not?('ie < 8').should be_true }
  end

  when_user_agent "Mozilla/5.0 (Windows NT 6.2; WOW64; rv:5.0) Gecko/20100101 Firefox/5.0" do
    specify { browser.vendor.should == :firefox }
    specify { browser.version.should == 5 }
    specify { browser.is_not?('ie < 8', 'firefox > 6').should be_true }
  end

  when_user_agent "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:2.0b8pre) Gecko/20101114 Firefox/4.0b8pre" do
    specify { browser.vendor.should == :firefox }
    specify { browser.version.should == 4.0 }
  end

  when_user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_2) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/14.0.835.186 Safari/535.1" do
    specify { browser.vendor.should == :chrome }
    specify { browser.version.should == 14 }
    specify { browser.is_not?('ie < 8', 'firefox < 6').should be_true }
  end

  when_user_agent "Mozilla/5.0 (Windows; U; MSIE 9.0; Windows NT 9.0; en-US)" do
    specify { browser.vendor.should == :ie }
    specify { browser.version.should == 9 }
    specify { browser.is?('firefox >= 5').should be_false }
  end

  when_user_agent "Mozilla/5.0 (Windows; U; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727)" do
    specify { browser.vendor.should == :ie }
    specify { browser.version.should == 6 }
    specify { browser.is?('chrome').should be_false }
    specify { browser.is_not?('chrome > 8').should be_true }
    specify { browser.is_not?('ie < 8', 'firefox < 6').should be_false }
  end

  when_user_agent "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_7; da-dk) AppleWebKit/533.21.1 (KHTML, like Gecko) Version/5.0.5 Safari/533.21.1" do
    specify { browser.vendor.should == :safari }
    specify { browser.version.should == 5 }
  end

  when_user_agent "Opera/9.80 (X11; Linux i686; U; ru) Presto/2.8.131 Version/11.11" do
    specify { browser.vendor.should == :opera }
    specify { browser.version.should == 11 }
  end
  
  when_user_agent "Opera/9.63 (X11; Linux x86_64; U; ru) Presto/2.1.1" do
    specify { browser.vendor.should == :opera }
    specify { browser.version.should == 9 }
  end

  when_user_agent "Something Else" do
    specify { browser.is?('chrome').should be_false }
    specify { browser.is_not?('ie < 8', 'firefox < 6').should be_true }
  end

  class MockController
    include LordBowser 

    def initialize(user_agent=nil)
      @user_agent = user_agent
    end

    def request
      @req ||= mock_req
    end

    def mock_req
      req = Object.new
      metaclass = class << req; self; end
      user_agent = @user_agent
      metaclass.send :define_method, :env, Proc.new { {'HTTP_USER_AGENT' => user_agent} }
      req
    end  
  end
end
