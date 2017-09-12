require 'selenium-webdriver'

module SeleniumUtil
class Browser
    def initialize type, option={}
        @me = Selenium::WebDriver.for type
        @retry = option[:retry] || 3 
        @timeout = option[:timeout] || 10
        @moment = option[:moment] || 0.5
        @op_splitter = option[:op_splitter] || ";"
        #@headless = option[:headless] || true#TODO
    end
    def method_missing(method, *args)
        @me.send(method, *args)
    end
    def navigate url, timeout=@timeout
        @me.navigate.to url
        wait_until_transfer url, timeout
    end
    def wait_until_transfer url, timeout=@timeout, moment=@moment
        while true
            if url.kind_of?(Regexp) then
                return if @me.current_url =~ url
            else
                return if @me.current_url == url
            end
            sleep @moment
            timeout -= @moment
            if timeout <= 0 then
                raise StandardError.new 'waiting transfer timeout.'
            end
        end
    end
    def find how, query, target=@me, _retry=@retry, moment=@moment
        _retry.times do
            begin
                _element = target.find_element how.to_sym, query
                return _element if _element.displayed?
            rescue=>e; 1; end
            sleep moment
        end
        raise StandardError.new "element not found: #{query}."
    end
    def finds how, query, target=@me, _retry=@retry, moment=@moment
        _retry.times do
            begin
                _elements = target.find_elements how, query
                return _elements if _elements.all?{|e| e.displayed? }
            rescue=>e; 1; end
            sleep moment
        end
        raise StandardError.new "elements not found: #{query}."
    end
    def set_value element, value#=>void
        tagname = element.tag_name
        case tagname
        when 'input' then
            type = element.attribute('type')
            if ['text', 'password', 'file'].include?(type) then
                element.send_keys value
            else
                raise StandardError.new "unknown input type of: #{type}."
            end
        when 'select' then
            Selenium::WebDriver::Support::Select.new(element).select_by(:value, value)            
        when 'textarea' then
            element.text = value
        else
            raise StandardError.new "unknown tagname of: #{tagname}."
        end
    end 

    def line_operations operations
        operations.each{|operation|
            puts "line_operation::#{operation}"
            _cmd, _arg1, _arg2, _arg3, _arg4, _arg5 = *operation.split(";")
            case _cmd
            when "c" then#click: how, query [, url]
                how, query, url = _arg1, _arg2, _arg3
                element = find(how, query)
                element.click
                wait_until_transfer(url) unless (url || "").empty?
            when "s" then#set value: how, query, value
                how, query, value = _arg1, _arg2, _arg3
                element = find(how, query)
                set_value element, value
            when "n" then#navigation url
                url = _arg1
                navigate url
            when "t" then#wait_transfer url
                url = _arg1
                wait_until_transfer url
            when "d" then#dialog: ok|cancel [, prompt_msg]
                click, prompt, url = _arg1, _arg2, _arg3
                dialog = @me.switch_to.alert
                dialog.send_keys(prompt) unless (prompt || "").empty?
                dialog.accept if click.to_sym == :ok
                dialog.dismiss if click.to_sym == :cancel
                wait_until_transfer(url) unless (url || "").empty?
            else;#TODO: error
                raise StandardError.new "unknown operation of: #{operation}."
            end
            sleep @moment
        }
    end

end#class
end#module
