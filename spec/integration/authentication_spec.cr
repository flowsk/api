require "../spec_helper.cr"

describe AppServer do
  visitor = AppVisitor.new

  it "signs in valid user" do
    # create a user
    user = UserBox.new.create

    # visit sign in endpoint
    visitor.post("/api/v1/sign_in", ({
      "sign_in:email"    => user.email,
      "sign_in:password" => "pass1234",
    }))

    # check response has status: 200 and retuns the token
    visitor.response.status_code.should eq 200
    json = JSON.parse(visitor.response.body)
    json["token"].should_not be_nil
  end

  it "creates user on sign up" do
    visitor.post("/api/v1/sign_up", ({
      "sign_up:name"                  => "New User",
      "sign_up:email"                 => "test@email.com",
      "sign_up:password"              => "password",
      "sign_up:password_confirmation" => "password",
    }))

    visitor.response.status_code.should eq 200
    json = JSON.parse(visitor.response.body)
    json["token"].should_not be_nil

    UserQuery.new.email("test@email.com").first.should_not be_nil
  end
end
