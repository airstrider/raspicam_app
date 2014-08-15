class Photo < ActiveRecord::Base
	belongs_to :user
	default_scope -> { order('created_at DESC') }
	validates :path,     presence: true
	validates :filename, presence: true
	validates :cam_id,   presence: true
	validates :user_id,  presence: true
end
