# Hack to always show Yanfly Enemy HP bars
class Enemy_HP_Gauge_Viewport < Viewport
  def gauge_visible?
    update_original_hide
    return true
  end
end