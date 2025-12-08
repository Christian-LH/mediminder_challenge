class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  helper_method :current_profile

  def current_profile
    @current_profile ||= if params[:profile_id]
                           Profile.find_by(id: params[:profile_id])
                         elsif session[:current_profile_id]
                           Profile.find_by(id: session[:current_profile_id])
                         else
                           current_user&.profiles&.first
                         end.tap do |profile|
      session[:current_profile_id] = profile.id if profile
    end
  end
end
