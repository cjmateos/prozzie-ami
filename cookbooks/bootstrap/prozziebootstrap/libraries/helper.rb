module ProzzieBootstrap
  module Helper

    def public_ip
      require 'net/http'
      require 'uri'

      uri_ip = URI.parse("http://169.254.169.254/2018-03-28/meta-data/public-ipv4")
      begin
        retries ||= 0
        response = Net::HTTP.get_response(uri_ip)
        if response.code != "200"
          raise 'Bad response code'
        else
          instance_ip = response.body
        end
      rescue
        retry if (retries += 1) < 5
      end
      instance_ip
    end

    def random_key(n)
      require 'securerandom'

      SecureRandom.urlsafe_base64(n)
    end
  end
end
