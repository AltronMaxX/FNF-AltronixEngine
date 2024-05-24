package altronix.ui.options;

import funkin.ui.AtlasText.AtlasFont;
import funkin.Preferences;
import flixel.FlxSprite;
import funkin.ui.options.PreferencesMenu;
import funkin.ui.TextMenuList.TextMenuItem;

class UIMenu extends PreferencesMenu
{
  public function new()
  {
    super();
    items.enabled = false; // We will handle controls for this page in update
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
  }

  function createPrefItemSwitch<T:Any>(prefName:String, prefDesc:String, onChange:T->Void, defaultValue:T):Void
  {
    var item:SwitchablePreferenceItem<T> = new SwitchablePreferenceItem<T>(0, 120 * (items.length - 1 + 1), prefName, AtlasFont.BOLD, function() {
      // onChange(value);
    });

    items.add(item);
  }
}

class SwitchablePreferenceItem<T:Any> extends TextMenuItem {}
