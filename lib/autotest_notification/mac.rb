module AutotestNotification
  class Mac
    @last_test_failed = false

    class << self
      
      def notify(title, msg, img, total = 1, failures = 0, priority = 0)
        system "growlnotify -n autotest --image #{img} #{'-s ' if ((failures > 0) and STICKY)}-p #{priority} -m '#{msg}' -t #{title}"
        play(SUCCESS_SOUND) unless SUCCESS_SOUND.empty? or failures > 0
        play(FAILURE_SOUND) unless FAILURE_SOUND.empty? or failures == 0
        say(total, failures) if SPEAKING
      end

      def say(total, failures)
        if failures > 0
          DOOM_EDITION ? Doom.play_sound(total, failures) : system("say #{failures} test#{'s' unless failures == 1} failed.")
          @last_test_failed = true
        elsif @last_test_failed
          DOOM_EDITION ? Doom.play_sound(total, failures) : system("say All tests passed successfully.")
          @last_test_failed = false
        end
      end
      
      def play(sound_file)
        `#{File.expand_path(File.dirname(__FILE__) + "/../../bin/")}/playsound #{sound_file}`
      end
      
    end
  end
end
