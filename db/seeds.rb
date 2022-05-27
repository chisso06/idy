# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
User.create!(
	hashed_id: "idy",
	name: "idy",
	user_name: "idy",
	email: "idy@example.com",
	image: "admin.png",
	password_digest: BCrypt::Password.create("password"),
	admin: 1
)

for i in 1..5 do
	User.create!(
		hashed_id: "test" + i.to_s,
		name: "test" + i.to_s,
		user_name: "test" + i.to_s,
		email: "test" + i.to_s + "@example.com",
		image: "admin.png",
		password_digest: BCrypt::Password.create("password"),
		admin: 0
	)
end
