package altronix.ui;

import sys.io.Process;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import funkin.graphics.FunkinSprite;
import funkin.ui.AtlasText;
import funkin.ui.MusicBeatState;
import funkin.ui.title.TitleState;

class UpdateState extends MusicBeatState
{
  public static var downloadStatus:DownloadingStatus = NOT_STARTED;

  var awailableTexts:FlxGroup;

  final textArray = ["New engine update!", "Press ENTER to download", "ESC to continue"];

  override function create():Void
  {
    var bg:FlxSprite = new FlxSprite(Paths.image('menuDesat'));
    bg.scrollFactor.x = 0;
    bg.scrollFactor.y = 0.17;
    bg.color = FlxColor.GREEN;
    bg.setGraphicSize(Std.int(bg.width * 1.2));
    bg.updateHitbox();
    bg.screenCenter();
    add(bg);

    awailableTexts = new FlxGroup();
    add(awailableTexts);

    for (i in 0...textArray.length)
    {
      var money:AtlasText = new AtlasText(0, 0, textArray[i], AtlasFont.BOLD);
      money.screenCenter(X);
      money.y += (i * 60) + 200;
      awailableTexts.add(money);
    }
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (FlxG.keys.justPressed.ENTER && downloadStatus == NOT_STARTED)
    {
      downloadStatus = DOWNLOADING;
      new Process('updater/AE-Updater' + #if windows '.exe' #else '' #end);
      Sys.exit(0);
    }
    if (FlxG.keys.justPressed.ESCAPE && downloadStatus == NOT_STARTED)
    {
      altronix.audio.MenuMusicHelper.cacheMenuMusic();
      FlxG.switchState(() -> new TitleState());
    }
  }
}

enum DownloadingStatus
{
  NOT_STARTED;
  DOWNLOADING;
  DOWNLOADED;
  UPDATING;
}
