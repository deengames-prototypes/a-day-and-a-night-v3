#==============================================================================
# ** MenuChanger
#------------------------------------------------------------------------------
#  This class modifies the in-game menu screen.
#  -- ADDS "Achievements" option
#==============================================================================

class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Monkey-patch the "Create Command Window" method.
  #--------------------------------------------------------------------------
  alias_method :original_create_command_window, :create_command_window
  def create_command_window
    original_create_command_window

    @command_window.set_handler(:achievements, method(:call_achievement_scene))
    @command_window.set_handler(:deeds, method(:call_deeds_scene))
  end

  #--------------------------------------------------------------------------
  # * Custom Menu Methods
  #--------------------------------------------------------------------------
  def call_achievement_scene
    SceneManager.call(AchievementsScene)
  end

  #--------------------------------------------------------------------------
  # * Custom Menu Methods
  #--------------------------------------------------------------------------
  def call_deeds_scene
    SceneManager.call(Scene_Deeds)
  end
end

class Window_MenuCommand < Window_Command
  #--------------------------------------------------------------------------
  # * Monkey-patch the "Custom Original Commands" method.
  #--------------------------------------------------------------------------
  alias_method :old_add_original_commands, :add_original_commands
  def add_original_commands
    old_add_original_commands

    add_command("Achievements", :achievements, true)
    add_command("Deeds", :deeds, true)
  end
end
