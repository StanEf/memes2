module Meme
  module Api
    class Create
      def self.call(params)
        params = params.clean!
        response = {}

        contract = contract(params)
        unless contract.success?
          response = {
              success: false,
              contract_errors: contract_errors
          }
          return response
        end

        external_api_params =
            params.
                merge({'template_id': params[:template][:external_id]}).
                delete(:template)
        result = Imgflip::Api::CaptionImage.call(external_api_params)
        response[:success] = result['success']
        if result['success']
          response.merge(data: result['data'])
          # тут надо сохранить мем локально в контексте пользователя
        else
          response.merge(external_api_error_message: result['error_message'])
        end

        response
      end

      def self.contract(params)
        # удалить все пустые ключи в params
        params = params.clean!
        Meme::Contracts::Create.new.call(params)
      end
    end
  end
end