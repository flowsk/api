class Api::V1::Tasks::Create < Api::V1::AuthenticatedAction
  route do
    CreateForm.create(params, current_user: current_user) do |form, task|
      if task
        json ShowSerializer.new(task)
      else
        json Errors::ShowSerializer.new("Could not save task", details: form.errors.join(", "))
      end
    end
  end
end
