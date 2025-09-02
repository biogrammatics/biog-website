admin_user = User.create!(
  email_address: "admin@biogrammatics.com",
  password: "admin123456",
  first_name: "Admin",
  last_name: "User",
  admin: true
)

puts "Admin user created successfully!"
puts "Email: admin@biogrammatics.com"
puts "Password: admin123456"
puts "Admin: #{admin_user.admin?}"
