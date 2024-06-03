package altronix.updater;

import altronix.github.GitHub.GitHubRelease;
import funkin.util.Constants;
import haxe.Http;
import haxe.Json;

class UpdateChecker
{
  /**
   * Checks game commit and latest release commit and returns true or false is we can update game.
   * @return Bool
   */
  public static function needUpdate():Bool
  {
    #if (!debug && sys && !linux) // TODO: Autocompile for linux
    var latestCommit = getLatestCommitHash();
    if (latestCommit != Constants.GIT_HASH && latestCommit != "") return true;
    #end
    return false;
  }

  static function getLatestCommitHash():String
  {
    var repoCommits:Array<String> = parseCommits(sendRequest("https://api.github.com/repos/Altronix-Team/FNF-AltronixEngine/commits"));
    var commit = getLatestReleaseCommit();
    if (commit != repoCommits[0])
    {
      for (i in 0...repoCommits.length)
      {
        if (commit == repoCommits[i])
        {
          trace('The last release commit is lagging behind the last repository commit by $i commits');
        }
      }
    }

    return commit;
  }

  static function getLatestReleaseCommit():String
  {
    var releasesCommits:Array<String> = parseReleases(sendRequest("https://api.github.com/repos/Altronix-Team/FNF-AltronixEngine/releases"));
    return Json.parse(sendRequest('https://api.github.com/repos/Altronix-Team/FNF-AltronixEngine/git/ref/tags/${releasesCommits[0]}'))?.object?.sha?.substr(0,
      7);
  }

  static function parseCommits(rawJson:String):Array<String>
  {
    if (rawJson == "") return null;
    var commits:Array<Dynamic> = Json.parse(rawJson);
    var ret:Array<String> = [];

    for (commit in commits)
    {
      var commitSha:String = commit.sha;
      commitSha = commitSha.substr(0, 7);
      ret.push(commitSha);
    }
    return ret;
  }

  static function parseReleases(rawJson:String):Array<String>
  {
    if (rawJson == "") return null;
    var commits:Array<GitHubRelease> = Json.parse(rawJson);
    var ret:Array<String> = [];

    for (commit in commits)
    {
      var commitSha:String = commit.tag_name;
      ret.push(commitSha);
    }
    return ret;
  }

  static function sendRequest(url:String):String
  {
    var ret:String = "";
    var http = new Http(url);
    http.setHeader("User-Agent", "request");
    http.onData = function(data:String) {
      ret = data;
    }
    http.onError = function(msg:String) {
      throw "Error while getting upstream commit! Message: " + msg;
    }
    http.request(false);

    return ret;
  }
}
