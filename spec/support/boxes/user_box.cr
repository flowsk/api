class UserBox < Avram::Box
  def initialize
    name "Celso Fernandes"
    email "#{sequence("user")}@gmail.com"
    encrypted_password Authentic.generate_encrypted_password("pass1234")
  end
end
