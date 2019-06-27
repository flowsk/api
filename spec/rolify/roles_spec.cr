require "../spec_helper.cr"

describe "Rolify" do
  it "add a role for user" do
    user = UserBox.new.create
    user.add_role(:admin)

    user.has_role?(:admin).should be_truthy
    user.has_role?(:foo).should be_falsey
  end

  it "add a role for a instance" do
    user = UserBox.new.create
    task1 = TaskBox.create
    task2 = TaskBox.create
    user.add_role(:owner, task1)

    user.has_role?(:owner, task1).should be_truthy
    user.has_role?(:owner, task2).should be_falsey
  end

  it "add a role for a class" do
    user = UserBox.new.create
    task1 = TaskBox.create
    task2 = TaskBox.create
    user.add_role(:owner, Task)

    user.has_role?(:owner, Task).should be_truthy
    user.has_role?(:owner, task1).should be_truthy
    user.has_role?(:owner, task2).should be_truthy
  end
end
