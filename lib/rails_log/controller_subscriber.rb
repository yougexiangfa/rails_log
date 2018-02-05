module RailsLog
  class ControllerSubscriber < ActiveSupport::LogSubscriber

    def header_processing(payload)
      return unless logger.debug?
      headers = request_headers(payload[:headers])

      debug "  Headers: #{headers.inspect}"
      debug "\n\n"
    end

    def process_action(event)
      payload = event.payload
      header_processing(payload)
      if payload[:exception].present?
        unless RailsLog.config.ignore_exception.include? payload[:exception_object].class.to_s
          lc = LogRecord.new
          lc.path = payload[:path]
          lc.controller = payload[:controller]
          lc.action = payload[:action]
          lc.params = filter_params(payload[:params])
          lc.headers = request_headers payload[:headers]
          lc.cookie = payload[:headers]['rack.request.cookie_hash']
          lc.session = payload[:headers]['rack.session'].to_hash
          lc.exception = payload[:exception].join("\r\n")
          lc.exception_object = payload[:exception_object].class.to_s
          lc.exception_backtrace = payload[:exception_object].backtrace.join("\r\n")
          lc.save
          info 'exception log saved!'
        end
      end
    end

    def logger
      ActionController::Base.logger
    end

    def request_headers(env)
      result = env.select { |k, _| k.start_with?('HTTP_') && k != 'HTTP_COOKIE' }
      result = result.collect { |pair| [pair[0].sub(/^HTTP_/, ''), pair[1]] }
      result.sort.to_h
    end

    def filter_params(params)
      filter_keys = ['controller', 'action']
      params.deep_transform_values { |v| v.to_s }.except(*filter_keys)
    end

  end
end

RailsLog::ControllerSubscriber.attach_to :action_controller