package altronix.ui.options;

import Type;
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
  var curSelected:Int = 0;
  var _items:Array<FlxSprite> = [];

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
    var item:SwitchableItem<T> = new SwitchableItem<T>(0, 120 * (items.length - 1 + 1), prefName, AtlasFont.BOLD, defaultValue);
    item.callback = function() {
      onChange(item.value);
    };

    items.add(item);
    preferenceItems.add(item);
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    updateControls();

    items.forEach(function(daItem:TextMenuItem) {
      if (items.selectedItem == daItem) daItem.x = 150;
      else
        daItem.x = 120;
    });
  }

  inline function updateControls():Void
  {
    var controls = PlayerSettings.player1.controls;

    if (controls.UI_UP_P || controls.UI_DOWN_P)
    {
      FunkinSound.playOnce(Paths.sound('scrollMenu'));
      navVertical(controls.UI_UP_P ? -1 : 1);
    }

    if (controls.UI_LEFT_P || controls.UI_RIGHT_P && (preferenceItems.members[curSelected] is SwitchableItem))
    {
      FunkinSound.playOnce(Paths.sound('scrollMenu'));
      var item:SwitchableItem<Any> = cast preferenceItems.members[curSelected];
      var ind = item.curSelected + (controls.UI_LEFT_P ? -1 : 1);

      if (ind > item.values.length - 1) ind = 0;
      if (ind < 0) ind = item.values.length - 1;
      item.curSelected = ind;
    }

    if (controls.ACCEPT && preferenceItems.members[curSelected] is PreferenceItem)
    {
      items.accept();
    }
  }

  function navVertical(ind:Int):Void
  {
    curSelected += ind;
    if (curSelected > preferenceItems.members.length - 1) curSelected = 0;
    if (curSelected < 0) curSelected = preferenceItems.members.length - 1;
    items.selectItem(curSelected);
    camFollow.y = items.selectedItem.y;
  }
}

class SwitchableItem<T:Any> extends TextMenuItem
{
  public var value:T;
  public var values:Array<T>;
  public var curSelected(default, set):Int = 0;

  var valueType:ValueType;
  var font:AtlasFont;

  public function new(x = 0.0, y = 0.0, name:String, font:AtlasFont = BOLD, defaultValue:T)
  {
    super(x, y, name, font);
    value = defaultValue;
    this.font = font;

    regenText();
  }

  function regenText():Void
  {
    var newText:String = '$name < $value >';
    this.label = new AtlasText(0, 0, newText, font);
  }

  function set_curSelected(val:Int):Int
  {
    curSelected = val;
    value = values[curSelected];
    regenText();
    return val;
  }
}
