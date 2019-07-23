class TasklistQuery < Tasklist::BaseQuery
  def find_in(ids : Array(Int64))
    ids.compact
    if ids.empty?
      TasklistQuery.new.where("1=0")
    else
      ids_sql = ids.to_s.sub("[", "(").sub("]", ")")
      TasklistQuery.new.where("id IN #{ids_sql}")
    end
  end

  def find_not_in(ids : Array(Int64))
    ids.compact
    if ids.empty?
      TaskQTasklistQueryuery.new
    else
      ids_sql = ids.to_s.sub("[", "(").sub("]", ")")
      TasklistQuery.new.where("id NOT IN #{ids_sql}")
    end
  end
end
