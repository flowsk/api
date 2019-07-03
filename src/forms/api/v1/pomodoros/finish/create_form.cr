class Api::V1::Pomodoros::Finish::CreateForm < Pomodoro::BaseForm
  needs current_user : User

  param_key :pomodoro

  def prepare
    set_status
    set_finished_at
  end

  private def set_status
    status.value = "finished"
  end

  private def set_finished_at
    finished_at.value = Time.utc
  end
end
