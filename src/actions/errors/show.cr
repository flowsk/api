class Errors::Show < Lucky::ErrorAction
  def handle_error(error : JSON::ParseException)
    message = "There was a problem parsing the JSON." +
              " Please check that it is formed correctly"

    json Errors::ShowSerializer.new(message), status: 400
  end

  def handle_error(error : Lucky::RouteNotFoundError)
    json Errors::ShowSerializer.new("Not found"), status: 404
  end

  # This is the catch all method that renders unhandled exceptions
  def handle_error(error : Exception)
    Lucky.logger.error(unhandled_error: error.inspect_with_backtrace)

    if Lucky::ErrorHandler.settings.show_debug_output
      # In development and test, render a debug page
      render_detailed_exception_page(error)
    else
      # Otherwise render a nice looking error for users
      render_unhandled_error(error)
    end
  end

  private def render_detailed_exception_page(error)
    Lucky::ErrorHandler.render_exception_page(context, error)
  end

  private def render_unhandled_error(error)
    message = "An unexpected error occurred"

    json Errors::ShowSerializer.new(message), status: 500
  end
end
