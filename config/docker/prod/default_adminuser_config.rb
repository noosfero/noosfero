admin = User.new(:login => ENV['ADMIN_LOGIN'],
                 :email => ENV['ADMIN_EMAIL'],
                 :password => ENV['ADMIN_PASSWORD'],
                 :password_confirmation => ENV['ADMIN_PASSWORD'],
                 :environment => Environment.default)

admin.save
admin.activate
Environment.default.add_admin(admin.person)
