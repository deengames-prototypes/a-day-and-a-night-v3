# http://forums.rpgmakerweb.com/index.php?/topic/2698-how-to-recover-hp-and-mp-when-you-level-up/#comment-29268
class Game_Actor < Game_Battler
  alias heal_on_level_up level_up
  #--------------------------------------------------------------------------
  # * Level Up
  #--------------------------------------------------------------------------
  def level_up
    heal_on_level_up
    recover_all
  end
end