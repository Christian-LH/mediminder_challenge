class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile
  has_many :notifications

  has_many :user_insurances
  has_many :health_insurances, through: :user_insurances

  has_many :user_services
  has_many :services, through: :user_services
end
