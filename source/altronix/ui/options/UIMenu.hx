package altronix.ui.options;

import flixel.FlxSprite;
import funkin.Paths;
import funkin.PlayerSettings;
import funkin.Preferences;
import funkin.audio.FunkinSound;
import funkin.ui.AtlasText;
import funkin.ui.TextMenuList.TextMenuItem;
import funkin.ui.options.PreferencesMenu;

class UIMenu extends PreferencesMenu
{
  public function new()
  {
    super();
  }

  override function createPrefItems():Void
  {
    createPrefItemCheckbox('Colored Health Bar', 'Changes default health bar colours to character dominant color from health icon', function(value:Bool):Void {
      Preferences.coloredHealthBar = value;
    }, Preferences.coloredHealthBar);
    createPrefItemCheckbox('Advanced Score Text', 'Changes funkin score text to altronix score text', function(value:Bool):Void {
      Preferences.advancedScoreText = value;
    }, Preferences.advancedScoreText);
    createPrefItemCheckbox('Song Position Bar', 'Adds song position ber', function(value:Bool):Void {
      Preferences.songPositionBar = value;
    }, Preferences.songPositionBar);
    createPrefItemCheckbox('Judgements Counter Text', 'Adds judgement counter text', function(value:Bool):Void {
      Preferences.judgementsText = value;
    }, Preferences.judgementsText);
  }
}
