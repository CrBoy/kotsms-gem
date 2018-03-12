require "net/http"
require "uri"
require "iconv"

class Kotsms
	API_HOST = "api.kotsms.com.tw"
	SMS_ENDPOINT = "/kotsmsapi-1.php"
	BULK_SMS_ENDPOINT = "/kotsmsapi-2.php"
	BALANCE_ENDPOOINT = "/memberpoint.php"
	STATUS_ENDPOOINT = "/msgstatus.php"

	def initialize(username, password)
		login(username, password)
	end

	def login(username, password)
		@username = username
		@password = password
		true
	end

	# recipient (string) - sms recipient in general format; e.g. '+886912345678'
	# message (string) - message content
	# options (hash) - optional config
	# options.ignore_cert (boolean) - Ignore SSL certificate or not
	# options.insecure (boolean) - Use plain HTTP or HTTPS
	# options.mode (string) - delivery mode
	#   'bit' - instant delivery (default)
	#   'bulk' - bulk delivery
	def deliver(recipient, message, options={})
		protocol = options[:insecure] ? "http" : "https"
		uri = URI.parse "#{protocol}://#{API_HOST}"
		uri.path = case (options[:mode].to_sym rescue nil)
				   when nil, :bit
					   SMS_ENDPOINT
				   when :bulk
					   BULK_SMS_ENDPOINT
				   else
					   raise StandardError.new "Bad delivering mode!"
				   end

		uri.query = URI.encode_www_form({
			username: @username,
			password: @password,
			dstaddr: recipient,
			smbody: Iconv.new("big5", "utf-8").iconv(message),
			dlvtime: (options[:dlvtime] rescue 0),
			vldtime: (options[:vldtime] rescue nil),
			response: (options[:response] rescue nil)
		})

		response = Net::HTTP.start(uri.host, use_ssl: uri.scheme == 'https') do |http|
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE if options[:ignore_cert]
			req = Net::HTTP::Get.new uri
			http.request(req)
		end

		parse_response(response.body)["kmsgid"].to_i
	end

	def deliver_bulk(recipient, message, options={})
		deliver(recipient, message, options.merge(mode: :bulk))
	end

	def balance
		uri = URI.parse(BALANCE_ENDPOOINT)
		uri.query = URI.encode_www_form({
			username: @username,
			password: @password
		})

		response = Net::HTTP.get_response(uri)

		response.body.to_i
	end

	def status(kmsgid)
		uri = URI.parse(STATUS_ENDPOOINT)
		uri.query = URI.encode_www_form({
			username: @username,
			password: @password,
			kmsgid: kmsgid
		})

		response = Net::HTTP.get_response(uri)

		parse_response(response.body)["statusstr"]
	end

	private

	def parse_response(response_body)
		array = URI::decode_www_form(response_body)
		Hash[array]
	end
end
