class Bot < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  belongs_to :developer

  acts_as_followable
  acts_as_taggable_on :tags

  mount_uploader :avatar, AvatarUploader
  mount_uploader :cover, CoverUploader

  validates :avatar, file_size: { less_than_or_equal_to: 2.megabytes }

  validates_length_of :bio, minimum: 1, maximum: 512 # validates length of bot's bio

  # ensure bot's username doesn't contain symbols nor special characters
  validates_format_of :username, with: /^[a-zA-Z0-9_-]*$/, multiline: true
  validates_length_of :username, minimum: 4, maximum: 32

  extend FriendlyId
  friendly_id :username, use: :slugged # username as friendly_id

  def timestamp
    created_at.strftime('%B %d %Y')
  end

  # Assign an API key on create
  before_create do |bot|
    bot.api_key = bot.generate_api_key
    bot.api_secret = bot.generate_api_secret
  end

  # Generate a unique API key
  def generate_api_key
    loop do
      token = SecureRandom.hex(16)
      break token unless Bot.exists?(api_key: token)
    end
  end

  # Generate a unique API secret
  def generate_api_secret
    loop do
      token = SecureRandom.hex(16)
      break token unless Bot.exists?(api_secret: token)
    end
  end
end
