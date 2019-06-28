require "../spec_helper.cr"

describe "Rolify" do
  describe "role queries" do
    it "add a role for user" do
      user = UserBox.new.create
      user.add_role(:admin)

      user.has_role?(:admin).should be_truthy
      user.has_role?(:foo).should be_falsey

      user.remove_role(:admin)
      user.has_role?(:admin).should be_falsey
    end

    it "add a role for a instance" do
      user = UserBox.new.create
      task1 = TaskBox.create
      task2 = TaskBox.create
      user.add_role(:owner, task1)

      user.has_role?(:owner, task1).should be_truthy
      user.has_role?(:owner, task2).should be_falsey

      user.remove_role(:owner, task1)
      user.has_role?(:owner, task1).should be_falsey
    end

    it "add a role for a class" do
      user = UserBox.new.create
      task1 = TaskBox.create
      task2 = TaskBox.create
      user.add_role(:owner, Task)

      user.has_role?(:owner, Task).should be_truthy
      user.has_role?(:owner, task1).should be_truthy
      user.has_role?(:owner, task2).should be_truthy

      user.remove_role(:owner, Task)

      user.has_role?(:owner, Task).should be_falsey
      user.has_role?(:owner, task1).should be_falsey
      user.has_role?(:owner, task2).should be_falsey
    end

    it "#check_strict role for an instance" do
      user = UserBox.new.create
      task1 = TaskBox.create
      task2 = TaskBox.create
      user.add_role(:owner, Task)

      user.has_role?(:owner, Task).should be_truthy
      user.has_strict_role?(:owner, task1).should be_falsey
      user.has_strict_role?(:owner, task2).should be_falsey
    end
  end

  describe "resource roles querying" do
    describe "instance level" do
      it "return the right roles" do
        user = UserBox.new.create
        role0 = user.add_role(:moderator, Task)

        task1 = TaskBox.create
        role1 = user.add_role(:owner, task1)

        task2 = TaskBox.create
        role2 = user.add_role(:owner, task2)

        roles1 = task1.roles
        expected_roles = [role1.id]
        roles1.size.should eq(1)
        roles1.each { |x| expected_roles.includes?(x.id).should be_truthy }

        roles1 = task1.applied_roles
        expected_roles = [role0.id, role1.id]
        roles1.size.should eq(2)
        roles1.each { |x| expected_roles.includes?(x.id).should be_truthy }
      end
    end

    describe "class level" do
      it "list of Task instances that have role `owner` bound to them" do
        user = UserBox.new.create

        task1 = TaskBox.create
        role1 = user.add_role(:owner, task1)

        task2 = TaskBox.create
        role2 = user.add_role(:admin, task2)

        tasks = Task.with_role(:owner)
        expected_tasks = [task1.id]
        tasks.size.should eq(1)
        tasks.each { |x| expected_tasks.includes?(x.id).should be_truthy }

        role2 = user.add_role(:owner, task2)

        expected_tasks = [task1.id, task2.id]
        tasks = Task.with_role(:owner)
        tasks.size.should eq(2)
        tasks.each { |x| expected_tasks.includes?(x.id).should be_truthy }
      end

      it "list of Task instances that do NOT have role `owner` bound to them" do
        user = UserBox.new.create

        task1 = TaskBox.create
        role1 = user.add_role(:owner, task1)

        task2 = TaskBox.create
        role2 = user.add_role(:admin, task2)

        tasks = Task.without_role(:owner)
        expected_tasks = [task2.id]
        tasks.size.should eq(1)
        tasks.each { |x| expected_tasks.includes?(x.id).should be_truthy }

        user.remove_role(:owner, task1)

        expected_tasks = [task1.id, task2.id]
        tasks = Task.without_role(:owner)
        tasks.size.should eq(2)
        tasks.each { |x| expected_tasks.includes?(x.id).should be_truthy }
      end
    end
  end
end
