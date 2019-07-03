require "../../../../spec_helper"

include ContextHelper

private def execute_action(id, user : User)
  context = get(user: user, params: {} of String => String)
  response = Api::V1::Tasks::Show.new(context, {"task_id" => id.to_s}).call
end

describe Api::V1::Tasks::Show do
  describe "security" do
    it "#security raise exception if user has no tasklist" do
      user = UserBox.create
      task1 = Api::V1::Tasks::CreateForm.create!(current_user: user, title: "User First Task")

      guest = UserBox.create

      expect_raises(UnauthorizedError, "You dont have access") do
        execute_action(task1.cuid, user: guest)
      end
    end

    it "#security raise not found if user has tasklist but not access to task" do
      user = UserBox.create
      task1 = Api::V1::Tasks::CreateForm.create!(current_user: user, title: "User First Task")

      guest = UserBox.create
      guest_task1 = Api::V1::Tasks::CreateForm.create!(current_user: guest, title: "Guest First Task")

      expect_raises(Avram::RecordNotFoundError, "Could not find first record in tasks") do
        execute_action(task1.cuid, user: guest)
      end
    end
  end

  it "shows a record" do
    user = UserBox.create
    task = Api::V1::Tasks::CreateForm.create!(current_user: user, title: "User First Task")

    response = execute_action(task.cuid, user: user)

    json = JSON.parse(response.body)
    json["id"].should eq(task.cuid)
  end
end
