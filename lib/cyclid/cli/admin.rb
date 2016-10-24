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

require 'base64'
require 'openssl'

require_rel 'admin/*.rb'

module Cyclid
  module Cli
    # 'admin' sub-command
    class Admin < Thor
      desc 'user', 'Manage users'
      subcommand 'user', AdminUser

      desc 'organization', 'Manage organizations'
      subcommand 'organization', AdminOrganization
      map 'org' => :organization
    end
  end
end
