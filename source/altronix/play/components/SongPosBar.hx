package altronix.play.components;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import funkin.Conductor;
import funkin.Paths;
import funkin.Preferences;
import funkin.graphics.FunkinSprite;
import funkin.play.PlayState;
import funkin.util.Constants;

class SongPosBar extends FlxTypedGroup<FlxObject>
{
  /**
   * The bar which displays the song position.
   * Dynamically updated based on the value of `songPositionPercent` (which is based on `songPosition`).
   */
  public var songPosBar:FlxBar;

  /**
   * The background image used for the song position bar.
   */
  public var songPosBarBG:FunkinSprite;

  /**
   * The FlxText displays song name and remaining time.
   */
  public var songText:FlxText;

  /**
   * The displayed value of the song position.
   * Used to provide smooth animations based on linear interpolation of the song position.
   */
  public var songPositionPercent:Float = 0;

  var songName:String;

  public function new()
  {
    super();

    songName = PlayState.instance.currentChart.songName;

    songPosBarBG = FunkinSprite.create(0, FlxG.height * 0.1 - 50, 'healthBar'); // Will use health bar because song position bar should have same view.
    songPosBarBG.screenCenter(X);
    songPosBarBG.scrollFactor.set(0, 0);
    songPosBarBG.zIndex = 802;
    songPosBarBG.cameras = [PlayState.instance.camHUD];
    add(songPosBarBG);

    songPosBar = new FlxBar(songPosBarBG.x + 4, songPosBarBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBarBG.width - 8), Std.int(songPosBarBG.height - 8), this,
      'songPositionPercent', 0, 2);
    songPosBar.scrollFactor.set();
    songPosBar.zIndex = 803;
    songPosBar.cameras = [PlayState.instance.camHUD];
    add(songPosBar);

    songText = new FlxText(songPosBarBG.x + (songPosBarBG.width / 2) - (songName.length * 5), songPosBarBG.y, 0, songName, 16);
    songText.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    songText.scrollFactor.set();
    songText.text = songName + ' (' + FlxStringUtil.formatTime(PlayState.instance.currentSongLengthMs, false) + ')';
    songText.y = songPosBarBG.y + 1;
    songText.zIndex = 804;
    songText.cameras = [PlayState.instance.camHUD];
    songText.screenCenter(X);

    add(songText);
  }

  /**
   * Creates song position bar.
   * Call only after characters initialization.
   */
  public function initSongPosBar():Void
  {
    songPosBar.createGradientBar([FlxColor.BLACK], [
      PlayState.instance.iconP1.getDominantColor(),
      PlayState.instance.iconP2.getDominantColor()
    ]);
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    songText.text = songName
      + ' ('
      + FlxStringUtil.formatTime(Math.floor((PlayState.instance.currentSongLengthMs - Conductor.instance.songPosition) / 1000), false)
      + ')';

    var value:Null<Float> = FlxMath.remapToRange(FlxMath.bound(Conductor.instance.songPosition / PlayState.instance.currentSongLengthMs, 0, 1), 0, 1, 0, 100);
    songPositionPercent = (value != null ? value : 0);

    songPosBar.percent = songPositionPercent;
  }
}
