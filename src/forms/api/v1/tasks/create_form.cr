private class TasklistForm < Tasklist::SaveOperation
  before_save :prepare

  def prepare
    cuid.value = Cuid.generate
  end
end

class Api::V1::Tasks::CreateForm < Task::SaveOperation
  needs current_user : User
  before_save :prepare

  param_key :task

  permit_columns title
  permit_columns completed

  def prepare
    validate_required title
    generate_cuid
    default_completed_value
    associate_with_tasklist
  end

  private def generate_cuid
    if params.nested("task").has_key?("id")
      cuid.value = params.nested("task")["id"]
    else
      cuid.value = Cuid.generate
    end
  end

  private def default_completed_value
    completed.value = false unless params.nested("task").has_key?("completed")
  end

  private def associate_with_tasklist
    tasklist = TasklistQuery.new.user_id(current_user.id).first?
    if tasklist
      tasklist_id.value = tasklist.id
    else
      new_tasklist = TasklistForm.create!(user_id: current_user.id)
      tasklist_id.value = new_tasklist.id
      current_user.add_role(:owner, new_tasklist)
    end
  end
end
