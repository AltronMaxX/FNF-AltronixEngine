package altronix.github;

// Some stuff from CodenameEngine
typedef GitHubRelease =
{
  var body:String;
  var url:String;
  var assets_url:String;
  var upload_url:String;
  var html_url:String;
  var id:Int;
  var author:GitHubUser;
  var node_id:String;
  var tag_name:String;
  var target_commitish:String;
  var name:String;
  var draft:Bool;
  var prerelease:Bool;
  var created_at:String;
  var published_at:String;
  var assets:Array<GitHubAsset>;
  var tarball_url:String;
  var zipball_url:String;
  var reactions:GitHubReactions;
}

typedef GitHubAsset =
{
  var url:String;
  var id:Int;
  var node_id:String;
  var name:String;
  var label:String;
  var uploader:GitHubUser;
  var content_type:String;
  var state:String;
  var size:UInt;
  var download_count:Int;
  var created_at:String;
  var updated_at:String;
  var browser_download_url:String;
}

typedef GitHubReactions =
{
  var url:String;
  var total_count:Int;
  var laugh:Int;
  var hooray:Int;
  var confused:Int;
  var heart:Int;
  var rocket:Int;
  var eyes:Int;
}

typedef GitHubUser =
{
  var login:String;
  var id:Int;
  var node_id:String;
  var avatar_url:String;
  var gravatar_id:String;
  var url:String;
  var html_url:String;
  var followers_url:String;
  var following_url:String;
  var gists_url:String;
  var starred_url:String;
  var type:GitHubUserType;
  var site_admin:Bool;
  var name:String;
  var company:String;
  var blog:String;
  var location:String;
  var email:String;
  var hireable:Null<Bool>;
  var bio:String;
  var twitter_username:String;
  var public_repos:Int;
  var public_gists:Int;
  var followers:Int;
  var following:Int;
  var created_at:String;
  var updated_at:String;
}

enum abstract GitHubUserType(String)
{
  var USER = "User";
  var ORGANIZATION = "Organization";
}
