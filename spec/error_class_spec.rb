require 'spec_helper'

describe Contentful::Error do
  let(:r) { Contentful::Response.new raw_fixture('not_found', 404) }

  describe '#response' do
    it 'returns the response the error has been initialized with' do
      expect(Contentful::Error.new(r).response).to be r
    end
  end

  describe '#message' do
    it 'returns the message found in the response json' do
      message = "HTTP status code: 404\n"\
                "Message: The resource could not be found.\n"\
                "Details: {\"type\"=>\"Entry\", \"space\"=>\"cfexampleapi\", \"id\"=>\"not found\"}\n"\
                "Request ID: 85f-351076632"
      expect(Contentful::Error.new(r).message).not_to be_nil
      expect(Contentful::Error.new(r).message).to eq message
    end

    describe 'message types' do
      describe 'default messages' do
        it '400' do
          response = Contentful::Response.new raw_fixture('default_400', 400)
          error = Contentful::Error[response.raw.status].new(response)

          message = "HTTP status code: 400\n"\
                    "Message: The request was malformed or missing a required parameter.\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end

        it '401' do
          response = Contentful::Response.new raw_fixture('default_401', 401)
          error = Contentful::Error[response.raw.status].new(response)

          message = "HTTP status code: 401\n"\
                    "Message: The authorization token was invalid.\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end

        it '403' do
          response = Contentful::Response.new raw_fixture('default_403', 403)
          error = Contentful::Error[response.raw.status].new(response)

          message = "HTTP status code: 403\n"\
                    "Message: The specified token does not have access to the requested resource.\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end

        it '404' do
          response = Contentful::Response.new raw_fixture('default_404', 404)
          error = Contentful::Error[response.raw.status].new(response)

          message = "HTTP status code: 404\n"\
                    "Message: The requested resource or endpoint could not be found.\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end

        it '429' do
          response = Contentful::Response.new raw_fixture('default_429', 429)
          error = Contentful::Error[response.raw.status].new(response)

          message = "HTTP status code: 429\n"\
                    "Message: Rate limit exceeded. Too many requests.\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end

        it '500' do
          response = Contentful::Response.new raw_fixture('default_500', 500)
          error = Contentful::Error[response.raw.status].new(response)

          message = "HTTP status code: 500\n"\
                    "Message: Internal server error.\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end

        it '502' do
          response = Contentful::Response.new raw_fixture('default_502', 502)
          error = Contentful::Error[response.raw.status].new(response)

          message = "HTTP status code: 502\n"\
                    "Message: The requested space is hibernated.\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end

        it '503' do
          response = Contentful::Response.new raw_fixture('default_503', 503)
          error = Contentful::Error[response.raw.status].new(response)

          message = "HTTP status code: 503\n"\
                    "Message: The request was malformed or missing a required parameter.\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end
      end

      describe 'special cases' do
        describe '400' do
          it 'details is a string' do
            response = Contentful::Response.new raw_fixture('400_details_string', 400)
            error = Contentful::Error[response.raw.status].new(response)

            message = "HTTP status code: 400\n"\
                      "Message: The request was malformed or missing a required parameter.\n"\
                      "Details: some error\n"\
                      "Request ID: 85f-351076632"
            expect(error.message).to eq message
          end

          it 'details is an object, internal errors are strings' do
            response = Contentful::Response.new raw_fixture('400_details_errors_string', 400)
            error = Contentful::Error[response.raw.status].new(response)

            message = "HTTP status code: 400\n"\
                      "Message: The request was malformed or missing a required parameter.\n"\
                      "Details: some error\n"\
                      "Request ID: 85f-351076632"
            expect(error.message).to eq message
          end

          it 'details is an object, internal errors are objects which have details' do
            response = Contentful::Response.new raw_fixture('400_details_errors_object', 400)
            error = Contentful::Error[response.raw.status].new(response)

            message = "HTTP status code: 400\n"\
                      "Message: The request was malformed or missing a required parameter.\n"\
                      "Details: some error\n"\
                      "Request ID: 85f-351076632"
            expect(error.message).to eq message
          end
        end

        describe '403' do
          it 'has an array of reasons' do
            response = Contentful::Response.new raw_fixture('403_reasons', 403)
            error = Contentful::Error[response.raw.status].new(response)

            message = "HTTP status code: 403\n"\
                      "Message: The specified token does not have access to the requested resource.\n"\
                      "Details: \n\tReasons:\n"\
                      "\t\tfoo\n"\
                      "\t\tbar\n"\
                      "Request ID: 85f-351076632"
            expect(error.message).to eq message
          end
        end

        describe '404' do
          it 'details is a string' do
            response = Contentful::Response.new raw_fixture('404_details_string', 404)
            error = Contentful::Error[response.raw.status].new(response)

            message = "HTTP status code: 404\n"\
                      "Message: The requested resource or endpoint could not be found.\n"\
                      "Details: The resource could not be found\n"\
                      "Request ID: 85f-351076632"
            expect(error.message).to eq message
          end

          describe 'has a type' do
            it 'type is on the top level' do
              response = Contentful::Response.new raw_fixture('404_type', 404)
              error = Contentful::Error[response.raw.status].new(response)

              message = "HTTP status code: 404\n"\
                        "Message: The requested resource or endpoint could not be found.\n"\
                        "Details: The requested Asset could not be found.\n"\
                        "Request ID: 85f-351076632"
              expect(error.message).to eq message
            end

            it 'type is not on the top level' do
              response = Contentful::Response.new raw_fixture('404_sys_type', 404)
              error = Contentful::Error[response.raw.status].new(response)

              message = "HTTP status code: 404\n"\
                        "Message: The requested resource or endpoint could not be found.\n"\
                        "Details: The requested Space could not be found.\n"\
                        "Request ID: 85f-351076632"
              expect(error.message).to eq message
            end
          end

          it 'can specify the resource id' do
            response = Contentful::Response.new raw_fixture('404_id', 404)
            error = Contentful::Error[response.raw.status].new(response)

            message = "HTTP status code: 404\n"\
                      "Message: The requested resource or endpoint could not be found.\n"\
                      "Details: The requested Asset could not be found. ID: foobar.\n"\
                      "Request ID: 85f-351076632"
            expect(error.message).to eq message
          end
        end

        describe '429' do
          it 'can show the time until reset' do
            response = Contentful::Response.new raw_fixture('default_429', 429, false, {'x-contentful-ratelimit-reset' => 60})
            error = Contentful::Error[response.raw.status].new(response)

            message = "HTTP status code: 429\n"\
                      "Message: Rate limit exceeded. Too many requests.\n"\
                      "Request ID: 85f-351076632\n"\
                      "Time until reset (seconds): 60"
            expect(error.message).to eq message
          end
        end
      end

      describe 'generic error' do
        it 'with everything' do
          response = Contentful::Response.new raw_fixture('other_error', 512)
          error = Contentful::Error[response.raw.status].new(response)

          message = "HTTP status code: 512\n"\
                    "Message: Some error occurred.\n"\
                    "Details: some text\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end

        it 'no details' do
          response = Contentful::Response.new raw_fixture('other_error_no_details', 512)
          error = Contentful::Error[response.raw.status].new(response)

          message = "HTTP status code: 512\n"\
                    "Message: Some error occurred.\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end

        it 'no request id' do
          response = Contentful::Response.new raw_fixture('other_error_no_request_id', 512)
          error = Contentful::Error[response.raw.status].new(response)

          message = "HTTP status code: 512\n"\
                    "Message: Some error occurred.\n"\
                    "Details: some text"
          expect(error.message).to eq message
        end

        it 'no message' do
          response = Contentful::Response.new raw_fixture('other_error_no_message', 512)
          error = Contentful::Error[response.raw.status].new(response)

          message = "HTTP status code: 512\n"\
                    "Message: The following error was received: {\n"\
                    "  \"sys\": {\n"\
                    "    \"type\": \"Error\",\n"\
                    "    \"id\": \"SomeError\"\n"\
                    "  },\n"\
                    "  \"details\": \"some text\",\n"\
                    "  \"requestId\": \"85f-351076632\"\n"\
                    "}\n"\
                    "\n"\
                    "Details: some text\n"\
                    "Request ID: 85f-351076632"
          expect(error.message).to eq message
        end

        it 'nothing' do
          response = Contentful::Response.new raw_fixture('other_error_nothing', 512)
          error = Contentful::Error[response.raw.status].new(response)

          message = "HTTP status code: 512\n"\
                    "Message: The following error was received: {\n"\
                    "  \"sys\": {\n"\
                    "    \"type\": \"Error\",\n"\
                    "    \"id\": \"SomeError\"\n"\
                    "  }\n"\
                    "}\n"
          expect(error.message).to eq message
        end
      end
    end
  end

  describe Contentful::UnparsableJson do
    describe '#message' do
      it 'returns the json parser\'s message' do
        uj = Contentful::Response.new raw_fixture('unparsable')
        expect(Contentful::UnparsableJson.new(uj).message).to \
            include 'unexpected token'
      end
    end
  end

  describe '.[]' do
    it 'returns BadRequest error class for 400' do
      expect(Contentful::Error[400]).to eq Contentful::BadRequest
    end

    it 'returns Unauthorized error class for 401' do
      expect(Contentful::Error[401]).to eq Contentful::Unauthorized
    end

    it 'returns AccessDenied error class for 403' do
      expect(Contentful::Error[403]).to eq Contentful::AccessDenied
    end

    it 'returns NotFound error class for 404' do
      expect(Contentful::Error[404]).to eq Contentful::NotFound
    end

    it 'returns ServerError error class for 500' do
      expect(Contentful::Error[500]).to eq Contentful::ServerError
    end

    it 'returns ServiceUnavailable error class for 503' do
      expect(Contentful::Error[503]).to eq Contentful::ServiceUnavailable
    end

    it 'returns generic error class for any other value' do
      expect(Contentful::Error[nil]).to eq Contentful::Error
      expect(Contentful::Error[200]).to eq Contentful::Error
    end
  end

end
