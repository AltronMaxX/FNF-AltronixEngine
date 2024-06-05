package funkin.ui.options;

import funkin.audio.FunkinSound;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import funkin.graphics.FunkinCamera;
import funkin.ui.AtlasText.AtlasFont;
import funkin.ui.TextMenuList.TextMenuItem;
import funkin.ui.options.OptionsState.Page;

class PreferencesMenu extends Page
{
  var items:TextMenuList;
  var preferenceItems:FlxTypedSpriteGroup<FlxSprite>;

  var menuCamera:FlxCamera;
  var camFollow:FlxObject;
  var curSelected:Int = 0;

  public function new()
  {
    super();

    menuCamera = new FunkinCamera('prefMenu');
    FlxG.cameras.add(menuCamera, false);
    menuCamera.bgColor = 0x0;
    camera = menuCamera;

    add(items = new TextMenuList());
    add(preferenceItems = new FlxTypedSpriteGroup<FlxSprite>());
    items.visible = false;
    items.enabled = false;

    createPrefItems();

    camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
    if (items != null) camFollow.y = items.selectedItem.y;

    menuCamera.follow(camFollow, null, 0.06);
    var margin = 160;
    menuCamera.deadzone.set(0, margin, menuCamera.width, 40);
    menuCamera.minScrollY = 0;

    items.onChange.add(function(selected) {
      camFollow.y = selected.y;
    });
  }

  /**
   * Create the menu items for each of the preferences.
   */
  function createPrefItems():Void
  {
    createPrefItemCheckbox('Naughtyness', 'Toggle displaying raunchy content', function(value:Bool):Void {
      Preferences.naughtyness = value;
    }, Preferences.naughtyness);
    createPrefItemCheckbox('Downscroll', 'Enable to make notes move downwards', function(value:Bool):Void {
      Preferences.downscroll = value;
    }, Preferences.downscroll);
    createPrefItemCheckbox('Flashing Lights', 'Disable to dampen flashing effects', function(value:Bool):Void {
      Preferences.flashingLights = value;
    }, Preferences.flashingLights);
    createPrefItemCheckbox('Camera Zooming on Beat', 'Disable to stop the camera bouncing to the song', function(value:Bool):Void {
      Preferences.zoomCamera = value;
    }, Preferences.zoomCamera);
    createPrefItemCheckbox('Debug Display', 'Enable to show FPS and other debug stats', function(value:Bool):Void {
      Preferences.debugDisplay = value;
    }, Preferences.debugDisplay);
    createPrefItemCheckbox('Auto Pause', 'Automatically pause the game when it loses focus', function(value:Bool):Void {
      Preferences.autoPause = value;
    }, Preferences.autoPause);
    createPrefItemSwitch('Menu music', 'Defines which menu music should be played.', function(value:String):Void {
      openfl.Assets.cache.clear(Preferences.menuMusic);
      Preferences.menuMusic = value;
      altronix.audio.MenuMusicHelper.cacheMenuMusic();
    }, Preferences.menuMusic, altronix.audio.MenuMusicHelper.avaiableMusic);
  }

  function createPrefItemSwitch<T:Any>(prefName:String, prefDesc:String, onChange:T->Void, defaultValue:T, defaultValues:Array<T>):Void
  {
    var item:SwitchableItem<T> = new SwitchableItem<T>(0, 120 * (items.length - 1 + 1), prefName, AtlasFont.BOLD, defaultValue, defaultValues);
    item.callback = function() {
      onChange(item.value);
    };

    items.add(item);
    preferenceItems.add(item);
  }

  function createPrefItemCheckbox(prefName:String, prefDesc:String, onChange:Bool->Void, defaultValue:Bool):Void
  {
    var checkbox:CheckboxPreferenceItem = new CheckboxPreferenceItem(0, 120 * (items.length - 1 + 1), defaultValue);

    var item = items.createItem(120, (120 * items.length) + 30, prefName, AtlasFont.BOLD, function() {
      var value = !checkbox.currentValue;
      onChange(value);
      checkbox.currentValue = value;
    });

    preferenceItems.add(new PreferenceItem(0, (120 * items.length) + 30, checkbox, item));
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    updateControls();

    // Indent the selected item.~~
    // TODO: Only do this on menu change?
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

    if (controls.ACCEPT && preferenceItems.members[curSelected] is PreferenceItem) items.accept();
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

class PreferenceItem extends FlxSprite
{
  var checkbox:CheckboxPreferenceItem;
  var text:FlxSprite;

  public function new(x:Float, y:Float, checkbox:CheckboxPreferenceItem, text:FlxSprite)
  {
    super(x, y);
    this.checkbox = checkbox;
    this.text = text;
  }

  override function draw():Void
  {
    checkbox.draw();
    text.draw();
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);
    checkbox.update(elapsed);
    text.update(elapsed);
  }
}

class CheckboxPreferenceItem extends FlxSprite
{
  public var currentValue(default, set):Bool;

  public function new(x:Float, y:Float, defaultValue:Bool = false)
  {
    super(x, y);

    frames = Paths.getSparrowAtlas('checkboxThingie');
    animation.addByPrefix('static', 'Check Box unselected', 24, false);
    animation.addByPrefix('checked', 'Check Box selecting animation', 24, false);

    setGraphicSize(Std.int(width * 0.7));
    updateHitbox();

    this.currentValue = defaultValue;
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    switch (animation.curAnim.name)
    {
      case 'static':
        offset.set();
      case 'checked':
        offset.set(17, 70);
    }
  }

  function set_currentValue(value:Bool):Bool
  {
    if (value)
    {
      animation.play('checked', true);
    }
    else
    {
      animation.play('static');
    }

    return currentValue = value;
  }
}

class SwitchableItem<T:Any> extends TextMenuItem
{
  public var value:T;
  public var values:Array<T>;
  public var curSelected(default, set):Int = 0;

  var font:AtlasFont;

  public function new(x = 0.0, y = 0.0, name:String, font:AtlasFont = BOLD, defaultValue:T, defaultValues:Array<T>)
  {
    super(x, y, name, font);
    value = defaultValue;
    values = defaultValues;
    this.font = font;

    regenText();
  }

  function regenText():Void
  {
    var newText:String = '$name < $value >';
    this.label.text = newText;
  }

  function set_curSelected(val:Int):Int
  {
    curSelected = val;
    value = values[curSelected];
    regenText();
    return val;
  }
}
