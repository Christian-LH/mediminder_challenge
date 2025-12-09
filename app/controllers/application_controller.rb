class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :icons
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

  def icons
    @icons = {
      1 => "fas fa-snowman",
      2 => "fas fa-robot",
      3 => "fas fa-user-astronaut",
      4 => "fa-solid fa-skull",
      5 => "fa-solid fa-spaghetti-monster-flying",
      6 => "fa-solid fa-ghost",
      7 => "fas fa-user-ninja",
      8 => "fas fa-user-secret",
      9 => "fa-solid fa-dragon"
    }
  end
end
