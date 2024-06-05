package altronix.ui;

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
  public static var downloadPercent:Float = 0.0;
  public static var downloadStatus:DownloadingStatus = NOT_STARTED;

  var downloadBar:FlxBar;
  var downloadText:AtlasText;
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

    downloadText = new AtlasText(0, 0, "Downloading...", AtlasFont.BOLD);
    downloadText.screenCenter(XY);
    downloadText.visible = false;
    add(downloadText);

    downloadBar = new FlxBar(0, FlxG.height - 40, LEFT_TO_RIGHT, FlxG.width, 40, "downloadPercent", 0, 1);
    downloadBar.createFilledBar(FlxColor.BLACK, FlxColor.LIME);
    downloadBar.visible = false;
    add(downloadBar);
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (FlxG.keys.justPressed.ENTER && downloadStatus == NOT_STARTED)
    {
      awailableTexts.visible = false;
      downloadText.visible = true;
      downloadBar.visible = true;
      downloadStatus = DOWNLOADING;
      sys.thread.Thread.create(() -> altronix.updater.Downloader.downloadLatestZip());
    }
    if (FlxG.keys.justPressed.ESCAPE && downloadStatus == NOT_STARTED)
    {
      altronix.audio.MenuMusicHelper.cacheMenuMusic();
      FlxG.switchState(() -> new TitleState());
    }

    if (downloadStatus == DOWNLOADING)
    {
      downloadBar.value = downloadPercent;
    }

    if (downloadStatus == DOWNLOADED)
    {
      downloadBar.visible = false;
      downloadText.text = "Updating...";
      downloadText.screenCenter(XY);
      downloadStatus = UPDATING;
      sys.thread.Thread.create(() -> altronix.updater.Updater.updateGame());
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
