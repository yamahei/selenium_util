require 'bundler'
Bundler.require

module SeleniumUtil
class Browser
    def initialize type, option={}
        @me = Selenium::WebDriver.for type
        @retry = option[:retry] || 3 
        @timeout = option[:timeout] || 10
        @moment = option[:moment] || 0.5
        #@headless = option[:headless] || true#TODO
    end
    def method_missing(method, *args)
        @me.send(method, *args)
    end
    def navigate url, timeout=@timeout
        @me.navigate.to url
        while true
            if url.kind_of?(Regexp) then
                return if @me.current_url =~ url
            else
                return if @me.current_url == url
            end
            sleep @moment
            timeout -= @moment
            if timeout <= 0 then
                raise StandardError.new 'Navigation timeout.'
            end
        end
    end
    def find how, query, target=@me
        @retry.times{
            begin; return target.find_element how, query
            rescue; sleep @moment
            end
        }
    end
    def finds how, query, target=@me
        @retry.times{
            begin; return target.find_elements how, query
            rescue; sleep @moment
            end
        }
    end

    def line_operations operations
        operations.split(";").each{|operation|
            _cmd, _how, _query, _value = *operation.split(":")
            _element = find(_how.to_sym, _query)
            case _cmd
            when "c" then;_element.click
            when "v" then;#TODO: set value
            when "w" then;#TODO: wait [url|how:query:[show|hide]]
            else;#TODO: error
            end
            sleep @moment
        }
    end
end#class
end#module
