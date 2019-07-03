class Api::V1::Pomodoros::CreateForm < Pomodoro::BaseForm
  needs current_user : User

  param_key :pomodoro

  fillable task_id

  def prepare
    generate_cuid
    default_status_value
    set_started_at
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
end
