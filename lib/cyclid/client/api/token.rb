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

module Cyclid
  # Cyclid client methods
  module Client
    # Client API HTTP methods
    module Api
      # JWT token based HTTP methods
      class Token < Base
        # Add the token to the request
        def authenticate_request(request, _uri)
          request.add_field('Authorization', "Token #{@config.username}:#{@config.token}")
          return request
        end
      end
    end
  end
end
