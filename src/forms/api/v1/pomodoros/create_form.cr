class Api::V1::Pomodoros::CreateForm < Pomodoro::SaveOperation
  needs task : Task
  needs current_user : User

  before_save :prepare

  param_key :pomodoro

  def prepare
    generate_cuid
    default_status_value
    set_started_at
    set_task_id
  end

  private def generate_cuid
    if params.nested("pomodoro").has_key?("id")
      cuid.value = params.nested("pomodoro")["id"]
    else
      cuid.value = Cuid.generate
    end
  end

  private def default_status_value
    status.value = "running"
  end

  private def set_started_at
    started_at.value = Time.utc
  end

  private def set_task_id
    task_id.value = task.id
  end
end
