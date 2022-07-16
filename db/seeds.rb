# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

User.create!(
	name: "idy",
	user_name: "idy",
	email: "idy@example.com",
	image: "admin.png",
	password_digest: BCrypt::Password.create("password"),
	activated: true,
	activated_at: Time.zone.now,
	admin: 1
)

for i in 1..10 do
	User.create!(
		name: "test" + i.to_s,
		user_name: "test" + i.to_s,
		email: "test" + i.to_s + "@example.com",
		image: "admin.png",
		password_digest: BCrypt::Password.create("password"),
		activated: true,
		activated_at: Time.zone.now,
		admin: 0
	)
end

users = User.all
user  = users.first
following = users[2..8]
followers = users[4..10]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }
