class User < ActiveRecord::Base
	attr_accessor :remember_token, :activation_token

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
	validates :name, presence: true, length: { maximum: 50}
	validates :email, presence: true, length: { maximum: 255},
						format: {with: VALID_EMAIL_REGEX},
						uniqueness: { case_sensitive: false }
	validates :password, length: { minimum: 6 }, allow_blank: true

	before_save { self.email = self.email.downcase}

	before_create :create_activation_digest

	# Returns the pasword digest of the password passed
	has_secure_password

	class << self
		# Returns the hash digest of the given string.
		#def User.digest(string)
		#def self.digest(string)
		def digest(string)
			cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost

			BCrypt::Password.create(string, cost: cost)
		end
		
		# Returns a random token.	
		#def User.new_token
		#def self.new_token
		def new_token
			SecureRandom.urlsafe_base64
		end
	end

	# Remembers a user in the database for use in persistent sessions.
	def remember
		self.remember_token = User.new_token
		update_attribute(:remember_digest, User.digest(remember_token))
	end

	# Returns true if the given token matches the digest.
	def authenticated?(remember_token)
		return false if remember_digest.nil?
		BCrypt::Password.new(remember_digest).is_password?(remember_token)
	end

	# Forgets a user.
	def forget
		update_attribute(:remember_digest, nil)
	end

	private
		# Creates and assigns the activation token and digest.
		def create_activation_digest
			self.activation_token = User.new_token
			self.activation_digest = User.digest(activation_token)
		end
end
