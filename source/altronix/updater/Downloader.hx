package altronix.updater;

import altronix.github.GitHub.GitHubRelease;
import altronix.ui.UpdateState;
import flixel.math.FlxMath;
import openfl.events.Event;
import openfl.events.ProgressEvent;
import openfl.net.URLRequest;
import openfl.net.URLStream;
import openfl.utils.ByteArray;
#if sys
import sys.io.File;
#end

class Downloader
{
  public static function downloadLatestZip():Void
  {
    #if sys
    var http = new haxe.Http("https://api.github.com/repos/Altronix-Team/FNF-AltronixEngine/releases");
    http.setHeader("User-Agent", "request");
    http.onData = function(data:String) {
      var latestRelease:GitHubRelease = cast haxe.Json.parse(data)[0];
      if (latestRelease == null)
      {
        throw "Error while downloading update! Latest release data is null";
      }

      var downloadURL:String = "";
      for (asset in latestRelease.assets)
      {
        if (asset.name == "engine.zip")
        {
          downloadURL = asset.browser_download_url;
        }
      }

      if (downloadURL == "")
      {
        throw "Error while downloading update! Unable to get download url";
      }

      final filePath:String = Sys.getCwd() + '/engine.zip';
      var downloadStream = new URLStream();
      downloadStream.addEventListener(Event.COMPLETE, function(event:Event) {
        var ba:ByteArray = new ByteArray();
        downloadStream.readBytes(ba);
        File.saveBytes(filePath, ba);
        downloadStream.close();
        UpdateState.downloadStatus = DOWNLOADED;
      });
      downloadStream.addEventListener(ProgressEvent.PROGRESS, function(event:ProgressEvent) {
        var percent = event.bytesLoaded / event.bytesTotal;
        if (percent != Math.NaN) UpdateState.downloadPercent = FlxMath.roundDecimal(percent, 2);
      });
      downloadStream.load(new URLRequest(downloadURL));
    }
    http.onError = function(msg:String) {
      throw "Error while downloading update! Unable to get latest release files. Message: " + msg;
    }
    http.request(false);
    #end
  }
}
