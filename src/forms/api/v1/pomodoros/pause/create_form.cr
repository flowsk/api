class Api::V1::Pomodoros::Pause::CreateForm < Pomodoro::SaveOperation
  needs current_user : User
  before_save :prepare

  param_key :pomodoro

  def prepare
    set_status
  end

  private def set_status
    status.value = "paused"
  end
end
