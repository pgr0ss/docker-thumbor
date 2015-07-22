#
# Author:: Enrico Stahn <mail@enricostahn.com>
#
# Copyright 2012-2015, Zanui <engineering@zanui.com.au>
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
#

require 'spec_helper'

# describe port(9000) do
#   it { should be_listening.with('tcp') }
# end

image_urls = {
  jpeg: 'placehold.it/300x120/E8117F/ffffff.jpg',
  gif: 'placehold.it/300x120/E8117F/ffffff.gif',
  png: 'placehold.it/300x120/E8117F/ffffff.png',
  webp: 'placehold.it/300x120/E8117F/ffffff.jpg'
}

describe server(:app) do
  # Test port is communicating and application is responding correctly
  describe http("http://app:9000/healthcheck") do
    it "responds content including 'WORKING'" do
      expect(response.body).to include('WORKING')
    end
  end

  image_urls.each do |format, url|
    request_url = "http://app:9000/unsafe/300x200/filters:format(#{format})/#{ERB::Util.url_encode(url)}"
    headers = { headers: { 'Accept:' => "image/#{format}" } }

    describe http(request_url, headers) do
      it 'responds successfully' do
        expect(response.status).to eq(200)
      end
      it "responds as 'image/#{format}'" do
        expect(response.headers['content-type']).to eq("image/#{format}")
      end
      it 'responds with the correct size' do
        expect(FastImage.size(StringIO.new(response.body))).to eq([300, 200])
      end
    end
  end
end
