# This file is intended to override ActiveModel::SecurePassword.
# However, ActiveModel::SecurePassword module extends ActiveSupport::Concern,
# which doesn't let Ruby's native "include" mechanism do its job.
# Instead, Concern handles Module's `append_features` method, and
# explicitly extends the including class (eg., ActiveRecord::Base)
# with ClassMethod module from ActiveModel::SecureModel.
# Moreover, it does this only once per class (this is achieved by
# checking `base < self`). Consequently:
# 1. If we simply add an overriding method `has_secure_password` to
# ActiveModel::SecurePassword, it won't be included in the class since
# the method ActiveModel::SecurePassword::has_secure_password was never
# included in the class, to begin with.
# 2. The overriding method has to be added to the ClassMethods
# module inside ActiveModel::SecurePassword. This is enough to change
# the behaviour of ActiveRecord::Base.has_secure_password. Since
# ActiveModel::SecurePassword already extends Concern, other classes
# that include ActiveModel::SecurePassword in the future will also
# get the new definition.
module ActiveModel
  module SecurePassword
    module ClassMethods
      def has_secure_password(options={})
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
    end
  end
end
