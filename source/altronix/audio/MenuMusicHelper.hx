package altronix.audio;

import funkin.Conductor;
import funkin.data.song.SongData.SongMusicData;
import funkin.data.song.SongRegistry;
import funkin.audio.FunkinSound;
import funkin.util.FileUtil;
import funkin.data.JsonFile;

class MenuMusicHelper
{
  /**
   * List of avaible menu music.
   */
  public static var avaiableMusic:Array<String> = [];

  /**
   * Lists all avaible menu music.
   */
  public static function initMusicList():Void
  {
    for (song in FileUtil.readDirContent(Paths.getLibraryPath('music/menuMusic/')))
    {
      if (FileUtil.doesFileExist(Paths.getLibraryPath('music/menuMusic/$song/$song-metadata.json')))
      {
        avaiableMusic.push(song);
      }
    }
  }

  /**
   * Caches current selected menu music.
   */
  public static function cacheMenuMusic():Void
  {
    FlxG.sound.cache(Paths.music('menuMusic/${Preferences.menuMusic}/${Preferences.menuMusic}'));
  }

  /**
   * Starts to play current selected menu music.
   * @return Whether the music was started. `false` if music was already playing or could not be started
   */
  public static function playMenuMusic(?params:FunkinSoundPlayMusicParams):Bool
  {
    return playMusic(Preferences.menuMusic, params ??
      {
        overrideExisting: true,
        restartTrack: false
      });
  }

  // Just copy from FunkinSound, cause we need to change Paths function
  static function playMusic(key:String, ?params:FunkinSoundPlayMusicParams):Bool
  {
    if (FlxG.sound.music?.playing)
    {
      if (FlxG.sound.music != null && Std.isOfType(FlxG.sound.music, FunkinSound))
      {
        var existingSound:FunkinSound = cast FlxG.sound.music;
        // Stop here if we would play a matching music track.
        @:privateAccess
        if (existingSound._label == Paths.music('menuMusic/$key/$key'))
        {
          return false;
        }
      }
    }

    if (FlxG.sound.music != null)
    {
      FlxG.sound.music.fadeTween?.cancel();
      FlxG.sound.music.stop();
      FlxG.sound.music.kill();
    }

    var songMusicData:Null<SongMusicData> = parseMusicData(key);
    // Will fall back and return null if the metadata doesn't exist or can't be parsed.
    if (songMusicData != null)
    {
      Conductor.instance.mapTimeChanges(songMusicData.timeChanges);
    }
    else
    {
      FlxG.log.warn('Tried and failed to find music metadata for $key');
    }

    var music = FunkinSound.load(Paths.music('menuMusic/$key/$key'), params?.startingVolume ?? 1.0, params.loop ?? true, false, true);
    if (music != null)
    {
      FlxG.sound.music = music;

      // Prevent repeat update() and onFocus() calls.
      FlxG.sound.list.remove(FlxG.sound.music);

      return true;
    }
    else
    {
      return false;
    }
  }

  static function parseMusicData(id:String, ?variation:String):Null<SongMusicData>
  {
    variation = variation == null ? Constants.DEFAULT_VARIATION : variation;

    var parser = new json2object.JsonParser<SongMusicData>();
    parser.ignoreUnknownVariables = false;

    switch (loadMusicDataFile(id, variation))
    {
      case {fileName: fileName, contents: contents}:
        parser.fromJson(contents, fileName);
      default:
        return null;
    }

    if (parser.errors.length > 0)
    {
      return null;
    }
    return parser.value;
  }

  static function loadMusicDataFile(id:String, ?variation:String):Null<JsonFile>
  {
    variation = variation == null ? Constants.DEFAULT_VARIATION : variation;
    var entryFilePath:String = Paths.file('music/menuMusic/$id/$id-metadata${variation == Constants.DEFAULT_VARIATION ? '' : '-$variation'}.json');
    if (!openfl.Assets.exists(entryFilePath)) return null;
    var rawJson:String = openfl.Assets.getText(entryFilePath);
    if (rawJson == null) return null;
    rawJson = rawJson.trim();
    return {fileName: entryFilePath, contents: rawJson};
  }
}
