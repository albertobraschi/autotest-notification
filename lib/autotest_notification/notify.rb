module AutotestNotification
  class Notify
    IMAGES_DIRECTORY      = File.expand_path(File.dirname(__FILE__) + "/../../images/")
    SUCCESS_IMAGE         = "#{IMAGES_DIRECTORY}/pass.png"
    FAIL_IMAGE            = "#{IMAGES_DIRECTORY}/fail.png"
    EXPIRATION_IN_SECONDS = 3
    Autotest.add_hook :ran_command do |at|
      result = at.results.is_a?(Array) ? at.results.last : at.results.split("\n").last

      if result
        %w{ test assertion error example pending failure }.each { |x| instance_variable_set "@#{x}s", result[/(\d+) #{x}/, 1].to_i }

        case result
        when /test/
          code = 31 if @failures > 0 || @errors > 0
          msg  = unit_test_message(@tests, @assertions, @failures, @errors)
        when /example/
          code = (@failures > 0) ? 31 : (@pendings > 0) ? 33 : 32
          msg  = rspec_message(@examples, @failures, @pendings)
        else
          code = 31
          msg  = "1 exception occurred"
          @failures = 1
        end

        if @failures > 0 || @errors > 0
          notify "FAIL", msg, FAIL_IMAGE, @tests + @examples, @failures + @errors, 2
        else
          notify "Pass", msg, SUCCESS_IMAGE, @tests + @examples
        end

        puts "\e[#{code}m#{'=' * 80}\e[0m\n\n"
      end
    end
    class << self
      
      def guess(so)
        handler = handlers.detect do |handler|
          handler.understands_so?(so)
        end
        handler
      end

      @@handlers = Array.new
      def add_handler(handler)
        @@handlers << handler
      end

      def handlers
        @@handlers
      end
      
      def notify(title, msg, img = SUCCESS_IMAGE, total = 1, failures = 0, pri = 0)
        img = Doom.image(total, failures, IMAGES_DIRECTORY) if DOOM_EDITION
        obj = guess(RUBY_PLATFORM)
        obj.notify(title, msg, img, total, failures, pri)
        obj.say(total, failures, obj) if SPEAKING
      end
      
      def say(total, failures, obj)
        if DOOM_EDITION
          Doom.play_sound(total, failures, obj)
        else
          obj.play_sound(failures)
        end
      end

      def pluralize(text, number)
        "#{number} #{text}#{'s' if number != 1}"
      end

      def unit_test_message(tests, assertions, failures, errors)
        "#{pluralize('test', tests)}, #{pluralize('assertion', assertions)}, #{pluralize('failure', failures)}, #{pluralize('error', errors)}"
      end

      def rspec_message(examples, failures, pendings)
        "#{pluralize('example', examples)}, #{pluralize('failure', failures)}, #{pluralize('pending', pendings)}"
      end
    end
  end
end
