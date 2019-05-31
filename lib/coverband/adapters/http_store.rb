# frozen_string_literal: true

require 'json'
require 'rest-client'

module Coverband
  module Adapters
    class HttpStore < Base

      def clear!
        raise RuntimeError, "#{self.class.name} does not implement the clear! method"
      end

      def clear_file!(_file)
        raise RuntimeError, "#{self.class.name} does not implement the clear_file! method"
      end

      def migrate!
        raise RuntimeError, "#{self.class.name} does not implement the migrate! method"
      end

      def size
        get_report.to_json.length
      end

      def size_in_mib
        format('%.2f', (size.to_f / 2**20))
      end

      protected

      def save_coverage(report)
        metadata = {}
        metadata = Coverband.configuration.remote_store.metadata_provider.new.data if Coverband.configuration.remote_store.metadata_provider
        RestClient::Request.execute(
          method: Coverband.configuration.remote_store_save_coverage_method,
          url: Coverband.configuration.remote_store_save_coverage_url,
          payload: {
            coverage_report: report,
            metadata: metadata
          }.to_json
          timeout: Coverband.configuration.remote_store_save_coverage_timeout,
          headers: {content_type: :json}
        )
      end

      def get_report(_type = nil)
        response = RestClient::Request.execute(
          method: Coverband.configuration.remote_store_get_coverage_method,
          url: Coverband.configuration.remote_store_get_coverage_url,
          timeout: Coverband.configuration.remote_store_get_coverage_timeout,
          headers: {accept: :json}
        )
        JSON.loads(response.body)
      end
    end
  end
end
