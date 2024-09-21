package funkin.api.discord;

#if FEATURE_DISCORD_RPC
import Sys.sleep;
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
#end

class DiscordClient
{
  #if FEATURE_DISCORD_RPC
  public function new()
  {
    trace("Discord Client starting...");
    final handlers:DiscordEventHandlers = DiscordEventHandlers.create();
    handlers.ready = cpp.Function.fromStaticFunction(onReady);
    handlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
    handlers.errored = cpp.Function.fromStaticFunction(onError);
    Discord.initialize("489437279799083028", handlers, true, null);
    trace("Discord Client started.");

    while (true)
    {
      Discord.updateConnection();

      Discord.runCallbacks();

      sleep(2);
    }

    Discord.shutdown();
  }

  public static function shutdown()
  {
    Discord.shutdown();
  }

  static function onReady(request:cpp.RawConstPointer<DiscordUser>)
  {
    final discordPresence:DiscordRichPresence = DiscordRichPresence.create();
    discordPresence.type = DiscordActivityType_Playing;
    discordPresence.state = null;
    discordPresence.details = "In the Menus";
    discordPresence.largeImageKey = "icon";
    discordPresence.largeImageText = "Friday Night Funkin'";
    Discord.updatePresence(discordPresence);
  }

  static function onError(errorCode:Int, message:cpp.ConstCharStar)
  {
    trace('Error! $errorCode : $message');
  }

  static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar)
  {
    trace('Disconnected! $errorCode : $message');
  }

  public static function initialize()
  {
    var DiscordDaemon = sys.thread.Thread.create(() -> {
      new DiscordClient();
    });
    trace("Discord Client initialized");
  }

  public static function changePresence(details:String, ?state:String, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float)
  {
    var startTimestamp:Float = if (hasStartTimestamp) Date.now().getTime() else 0;

    if (endTimestamp > 0)
    {
      endTimestamp = startTimestamp + endTimestamp;
    }

    final discordPresence:DiscordRichPresence = DiscordRichPresence.create();
    discordPresence.type = DiscordActivityType_Playing;
    discordPresence.state = state;
    discordPresence.details = details;
    discordPresence.largeImageKey = "icon";
    discordPresence.largeImageText = "Friday Night Funkin'";
    discordPresence.smallImageKey = smallImageKey;
    discordPresence.startTimestamp = Std.int(startTimestamp / 1000);
    discordPresence.endTimestamp = Std.int(endTimestamp / 1000);
    Discord.updatePresence(discordPresence);

    // trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
  }
  #end
}
