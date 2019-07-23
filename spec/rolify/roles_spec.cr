require "../spec_helper.cr"

private def verify_tasks(tasks : Avram::Query, expected : Array(Int64))
  tasks.size.should eq(expected.size)
  tasks.each { |x| expected.should contain(x.id) }
end

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
        roles1.each { |x| expected_roles.should contain(x.id) }

        roles1 = task1.applied_roles
        expected_roles = [role0.id, role1.id]
        roles1.size.should eq(2)
        roles1.each { |x| expected_roles.should contain(x.id) }
      end
    end

    describe "class level" do
      it "list of Task instances that have role `owner` bound to them" do
        user = UserBox.new.create

        task1 = TaskBox.create
        role1 = user.add_role(:owner, task1)

        task2 = TaskBox.create
        role2 = user.add_role(:admin, task2)

        Task.with_role(:foo).size.should eq(0)

        tasks = Task.with_role(:owner)
        verify_tasks(tasks: tasks, expected: [task1.id])

        role2 = user.add_role(:owner, task2)

        tasks = Task.with_role(:owner)
        verify_tasks(tasks: tasks, expected: [task1.id, task2.id])
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
        tasks.each { |x| expected_tasks.should contain(x.id) }

        user.remove_role(:owner, task1)

        tasks = Task.without_role(:owner)
        verify_tasks(tasks: tasks, expected: [task1.id, task2.id])
      end

      it "list of Task instances that have role `owner` bound to them and belong to user roles" do
        user = UserBox.new.create
        guest = UserBox.new.create

        task1 = TaskBox.create
        role1 = user.add_role(:owner, task1)
        guest_role = guest.add_role(:owner, task1)

        task2 = TaskBox.create
        role2 = user.add_role(:admin, task2)

        tasks = Task.with_role(:owner, user)
        verify_tasks(tasks: tasks, expected: [task1.id])

        Task.with_role(:foo, user).size.should eq(0)
      end

      it "list of Task instances that have role `owner` or `user` bound to them and belong to user roles" do
        user = UserBox.new.create
        guest = UserBox.new.create

        task1 = TaskBox.create
        user.add_role(:owner, task1)

        task2 = TaskBox.create
        user.add_role(:admin, task2)
        guest.add_role(:admin, task2)

        task3 = TaskBox.create
        user.add_role(:foo, task3)

        tasks = Task.with_role([:admin, :owner], user)
        verify_tasks(tasks: tasks, expected: [task1.id, task2.id])
      end
    end
  end
end
