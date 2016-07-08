class Game_Player < Game_Character
  SWIMMING_TAG = 1 # Terrain tag indicating where we can swim
  PLAYER_IS_SWIMMING_SWITCH = 2 # Switch indicating that we're swimming
  #--------------------------------------------------------------------------
  # * Determine if Map is Passable
  #--------------------------------------------------------------------------
  def map_passable?(x, y, d)
    case @vehicle_type
    when :boat
      $game_map.boat_passable?(x, y)
    when :ship
      $game_map.ship_passable?(x, y)
    when :airship
      true
    else    
      (can_swim?(x,y) ? true : super)
    end
  end
  #--------------------------------------------------------------------------
  # * Determine if Actor can Swim
  #--------------------------------------------------------------------------
  def can_swim?(x,y)
	return $game_switches[PLAYER_IS_SWIMMING_SWITCH] && $game_map.terrain_tag(x, y) == SWIMMING_TAG
  end  
end