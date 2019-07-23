class Api::V1::Pomodoros::Unpause::CreateForm < Pomodoro::SaveOperation
  needs current_user : User
  before_save :prepare

  param_key :pomodoro

  def prepare
    set_status
  end

  private def set_status
    status.value = "running"
  end
end
