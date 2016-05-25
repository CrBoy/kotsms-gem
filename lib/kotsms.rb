require "net/http"
require "uri"
require "iconv"

class Kotsms
	SMS_ENDPOINT = "http://202.39.48.216/kotsmsapi-1.php"
	BULK_SMS_ENDPOINT = "http://202.39.48.216/kotsmsapi-2.php"
	ENCRYPTED_SMS_ENDPOINT = "https://api.kotsms.com.tw/kotsmsapi-1.php"
	ENCRYPTED_BULK_SMS_ENDPOINT = "https://api.kotsms.com.tw/kotsmsapi-2.php"
	BALANCE_ENDPOOINT = "http://mail2sms.com.tw/memberpoint.php"
	STATUS_ENDPOOINT = "http://mail2sms.com.tw/msgstatus.php"

	def initialize(username, password)
		login(username, password)
	end

	def login(username, password)
		@username = username
		@password = password
		true
	end

	def deliver(dst, content, options={})
		endpoint = case (options[:mode].to_sym rescue nil)
                           when nil, :bit
                            SMS_ENDPOINT
                           when :bulk
                            BULK_SMS_ENDPOINT
                           when :encrypted_bit
                            ENCRYPTED_SMS_ENDPOINT
                           when :encrypted_bulk
                            ENCRYPTED_BULK_SMS_ENDPOINT
                           else
                            raise StandardError.new "Bad delivering mode!"
                           end
		uri = URI.parse(endpoint)


		uri.query = URI.encode_www_form({
			username: @username,
			password: @password,
			dstaddr: dst,
			smbody: Iconv.new("big5", "utf-8").iconv(content),
			dlvtime: (options[:dlvtime] rescue 0),
			vldtime: (options[:vldtime] rescue nil),
			response: (options[:response] rescue nil)
		})

		response = Net::HTTP.get_response(uri)

		parse_response(response.body)["kmsgid"].to_i
	end

	def deliver_bulk(dst, content, options={})
		deliver(dst, content, options.merge(mode: :bulk))
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
