module ActiveRecord
  class Base
    include ActiveModel::SecurePassword
    # ActiveRecord::Base includes ActiveModel::SecurePassword.
    # I tried to override ActiveModel::SecurePassword, but it didn't
    # work (See secure_password.rb for explanation).
    # Therefore, I am directly including these methods in Base.
    # Note: for these new definitions to override old ones in
    # ActiveModel::SecurePassword, this file has to be loaded after
    # the require of active_record.

=begin
    puts "Class Base reopened. has_secure_password being added."
    def self.has_secure_password(options={})
      include Module.new {
        attr_reader :password, :password_confirmation
        def password=(unencrypted_password)
          @password = unencrypted_password
          self.password_digest = SymbolicString.new "#{name}.password_digest"
        end

        def password_confirmation=(unencrypted_password)
          @password_confirmation = unencrypted_password
        end
      }
    end
=end
  end
end
