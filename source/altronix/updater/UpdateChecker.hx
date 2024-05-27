package altronix.updater;

import funkin.util.Constants;
import haxe.Http;
import haxe.Json;

class UpdateChecker
{
  public static function needUpdate():Bool
  {
    #if (!debug && sys)
    var latestCommit = getLatestCommitHash();
    if (latestCommit != Constants.GIT_HASH && latestCommit != "") return true;
    #end
    return false;
  }

  static function getLatestCommitHash():String
  {
    var ret:String = "";
    var http = new Http("https://api.github.com/repos/Altronix-Team/FNF-AltronixEngine/branches/develop");
    http.setHeader("User-Agent", "request");
    http.onData = function(data:String) {
      var commit:String = Json.parse(data)?.commit?.sha;
      ret = commit.substr(0, 7);
    }
    http.onError = function(msg:String) {
      throw "Error while getting upstream commit! Message: " + msg;
    }
    http.request(false);
    return ret;
  }
}
