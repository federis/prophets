require 'devise/strategies/token_authenticatable'
module Devise
  module Strategies
    class TokenAuthenticatable < Authenticatable
      def params_auth_hash
        return_params = if params[scope].kind_of?(Hash) && params[scope].has_key?(authentication_keys.first)
            params[scope]
          else
            params
          end
        token = ActionController::HttpAuthentication::Token.token_and_options(request)
        return_params.merge!(:auth_token => token[0]) if token
        return_params
      end
    end
  end
end