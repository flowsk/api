class TaskQuery < Task::BaseQuery
  def find_in(ids : Array(Int64))
    ids.compact
    if ids.empty?
      TaskQuery.new.where("1=0")
    else
      ids_sql = ids.to_s.sub("[", "(").sub("]", ")")
      TaskQuery.new.where("id IN #{ids_sql}")
    end
  end

  def find_not_in(ids : Array(Int64))
    ids.compact
    if ids.empty?
      TaskQuery.new
    else
      ids_sql = ids.to_s.sub("[", "(").sub("]", ")")
      TaskQuery.new.where("id NOT IN #{ids_sql}")
    end
  end
end
