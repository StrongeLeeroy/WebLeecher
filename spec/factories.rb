# By using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |user|
  user.name                  "Gorka Hernandez"
  user.email                 "gorka91@gmail.com"
  user.password              "foobar"
  user.password_confirmation "foobar"
end
