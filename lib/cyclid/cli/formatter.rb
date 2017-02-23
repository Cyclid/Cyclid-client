# frozen_string_literal: true
# Copyright 2016 Liqwyd Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'colorize'

module Cyclid
  module Cli
    # Output formatter
    module Formatter
      # Output with no additional formatting
      class Base
        class << self
          def puts(title, *args)
            t = if args.empty?
                  title
                else
                  "#{title}: "
                end
            Kernel.puts t + args.join
          end
          alias colorize puts

          def ask(question)
            print "#{question}: "
          end
        end
      end

      # Output with XTerm compatible color
      class Terminal < Base
        class << self
          def colorize(title, *args)
            t = if args.empty?
                  title
                else
                  "#{title}: "
                end
            Kernel.puts t.colorize(:cyan) + args.join
          end

          def ask(question)
            print "#{question}: ".colorize(:red)
          end
        end
      end

      class << self
        def method_missing(method, *args, &block) # rubocop:disable Style/MethodMissing
          @formatter ||= get
          @formatter.send(method, *args, &block)
        end

        private

        def get
          STDOUT.tty? ? Terminal : Base
        end
      end
    end
  end
end
