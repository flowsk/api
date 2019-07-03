require "../../../../spec_helper"

include ContextHelper

private def execute_action(id, user : User)
  context = delete(user: user, params: {} of String => String)
  response = Api::V1::Tasks::Delete.new(context, {"task_id" => id}).call
end

describe Api::V1::Tasks::Delete do
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

  it "deletes a record" do
    user = UserBox.create
    task = Api::V1::Tasks::CreateForm.create!(current_user: user, title: "User First Task")

    response = execute_action(task.cuid, user: user)

    expect_raises(Avram::RecordNotFoundError, "Could not find tasks with id of #{task.id}") do
      TaskQuery.find(task.id)
    end
  end
end
