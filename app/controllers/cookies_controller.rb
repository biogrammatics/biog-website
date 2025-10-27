class CookiesController < ApplicationController
  allow_unauthenticated_access only: [ :update_consent, :policy, :privacy ]

  def update_consent
    consent_params = params.permit(:essential, :analytics, :marketing)

    # Essential cookies are always required
    cookies.permanent[:cookie_consent] = {
      value: {
        essential: true,
        analytics: consent_params[:analytics] == "true",
        marketing: consent_params[:marketing] == "true",
        timestamp: Time.current.iso8601
      }.to_json,
      httponly: false, # Needs to be readable by JavaScript
      secure: Rails.env.production?,
      same_site: :lax
    }

    # Note: Analytics and marketing cookie clearing will be implemented when
    # third-party tracking is added to the application

    respond_to do |format|
      format.json { render json: { status: "success" } }
      format.html { redirect_back(fallback_location: root_path, notice: "Cookie preferences updated") }
    end
  end

  def policy
    # Render cookie policy page
  end

  def privacy
    # Render privacy policy page
  end
end
