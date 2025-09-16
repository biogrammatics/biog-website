module CookiesHelper
  def cookie_consent_given?
    cookies[:cookie_consent].present?
  end

  def cookie_consent
    return @cookie_consent if defined?(@cookie_consent)

    @cookie_consent = if cookies[:cookie_consent].present?
      JSON.parse(cookies[:cookie_consent]).with_indifferent_access
    else
      { essential: false, analytics: false, marketing: false }
    end
  rescue JSON::ParserError
    { essential: false, analytics: false, marketing: false }
  end

  def analytics_cookies_allowed?
    cookie_consent[:analytics] == true
  end

  def marketing_cookies_allowed?
    cookie_consent[:marketing] == true
  end

  def show_cookie_banner?
    !cookie_consent_given?
  end
end
