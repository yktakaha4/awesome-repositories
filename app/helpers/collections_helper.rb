module CollectionsHelper
  def create_next_sort_params(name, param_order, param_direction)
    top = %w(name author license).include?(name) ? "asc" : "desc"
    bottom = top == "asc" ? "desc" : "asc"
    if !param_order.nil? && !param_direction.nil? then
      if param_order == name then
        if param_direction == top then
          return { :order => name, :direction => bottom }
        else
          return { :order => nil, :direction => nil }
        end
      end
    end
    return { :order => name, :direction => top }
  end
  
  def create_sort_icon_class(name, param_order, param_direction)
    top = %w(name author license).include?(name) ? "asc" : "desc"
    if !param_order.nil? && !param_direction.nil? then
      if param_order == name then
        if param_direction == top then
          return "fa fa-sort-up"
        else
          return "fa fa-sort-down"
        end
      end
    end
    return "fa fa-sort"
  end
end
