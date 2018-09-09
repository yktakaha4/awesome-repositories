module ApplicationHelper
  def simple_time(time)
    time.nil? ? "" : time.strftime("%Y/%m/%d %H:%M:%S %Z")
  end 
end
