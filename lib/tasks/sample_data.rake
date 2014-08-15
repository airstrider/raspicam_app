namespace :db do 
	desc "Fill database with sample data"
	task populate: :environment do
		make_users
		make_microposts
		make_relationships
		make_photos
	end
end

def make_users
	admin = User.create!(name: "Example User",
						 email: "example@railstutorial.org",
						 password: "foobar",
						 password_confirmation: "foobar",
						 admin: true)
	10.times do |n|
		name = Faker::Name.name
		email = "example-#{n+1}@railstutorial.org"
		password = "password"
		User.create!(name: name,
					 email: email,
					 password: password,
					 password_confirmation: password)
	end
end

def make_microposts
	users = User.all(limit: 6)
	35.times do
		content = Faker::Lorem.sentence(5)
		users.each { |user| user.microposts.create!(content: content) }
	end
end

def make_relationships
	users = User.all
	user  = users.first
	followed_users = users[2..9]
	followers      = users[3..8]
	followed_users.each { |followed| user.follow!(followed) }
	followers.each      { |follower| follower.follow!(user) } 	
end

def make_photos
	users     = User.all
	user      = users.first
	path      = "1/"
	filename1 = "20140808_143139.jpeg"
	filename2 = "20140809_105804.jpeg"
	cam_id    = "raspicam_01"

	user.photos.create!(path: path, filename: filename1, cam_id: cam_id)
	user.photos.create!(path: path, filename: filename2, cam_id: cam_id)
end