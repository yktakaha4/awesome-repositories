module ApplicationHelper
  def simple_time(time)
    time.strftime("%Y/%m/%d %H:%M:%S %Z")
  end 
end
