# Copyright (c) 2018 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'rainbow'

STDOUT.sync = true

# The log.
# Author:: Yegor Bugayenko (yegor256@gmail.com)
# Copyright:: Copyright (c) 2018 Yegor Bugayenko
# License:: MIT
module Zold
  # Logging
  module Log
    # Extra verbose log
    class Verbose
      def debug(msg)
        print(msg)
      end

      def debug?
        true
      end

      def info(msg)
        print(msg)
      end

      def info?
        true
      end

      def error(msg)
        print("#{Rainbow('ERROR').red}: #{msg}")
      end

      private

      def print(text)
        puts(text)
      end
    end

    # Regular log
    class Regular
      def debug(msg)
        # nothing
      end

      def debug?
        false
      end

      def info(msg)
        print(msg)
      end

      def info?
        true
      end

      def error(msg)
        print("#{Rainbow('ERROR').red}: #{msg}")
      end

      private

      def print(text)
        puts(text)
      end
    end

    # Log that doesn't log anything
    class Quiet
      def debug(msg)
        # nothing to do here
      end

      def debug?
        false
      end

      def info(msg)
        # nothing to do here
      end

      def info?
        false
      end

      def error(msg)
        # nothing to do here
      end
    end
  end
end
