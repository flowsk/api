class Api::V1::Pomodoros::Pause::CreateForm < Pomodoro::BaseForm
  needs current_user : User

  param_key :pomodoro

  def prepare
    set_status
  end

  private def set_status
    status.value = "paused"
  end
end
