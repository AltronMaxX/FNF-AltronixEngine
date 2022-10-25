package;

import openfl.display.Bitmap;
import lime.app.Application;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import GameJolt.GJToastManager;
import openfl.events.UncaughtErrorEvent;
import Debug;
import openfl.system.Capabilities;
import haxe.CallStack;
import utils.EngineSave;

#if FEATURE_MODCORE
import ModCore;
#end

//TODO Altronix Engine start splash
class Main extends Sprite
{
	public static var gjToastManager:GJToastManager;
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = states.TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	public static var isHidden:Bool = false;

	public static var bitmapFPS:Bitmap;

	public static var instance:Main;

	/**
	 * Custom FlxSave code to work without init of FlxG
	 */
	public static var save(default, null):EngineSave = new EngineSave();

	public static var watermarks = true; // Whether to put Altronix Engine literally anywhere

	public static var memoryCount = true;

	// You can pretty much ignore everything from here on - your code should go in your states.
	// Ho-ho-ho, no

	public static function main():Void
	{
		// quick checks

		Lib.current.addChild(new Main());
	}

	public function new()
	{
		instance = this;

		super();

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = 1280;
		var stageHeight:Int = 720;

		save.bind('funkin', 'ninjamuffin99');

		EngineData.initSave();

		KeyBinds.keyCheck();

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !cpp
		framerate = 60;
		#end

		// Run this first so we can see logs.
		Debug.onInitProgram();

		#if !mobile
		fpsCounter = new EngineFPS(10, 3, 0xFFFFFF);
		bitmapFPS = ImageOutline.renderImage(fpsCounter, 1, 0x000000, true);
		bitmapFPS.smoothing = true;
		#end		

		if (save.data.fullscreenOnStart == null)
			save.data.fullscreenOnStart = false;

		game = new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, save.data.fullscreenOnStart);
		addChild(game);

		#if !mobile
		addChild(fpsCounter);
		toggleFPS(FlxG.save.data.fps);
		#end

		gjToastManager = new GJToastManager();
		addChild(gjToastManager);

		// Finish up loading debug tools.
		Debug.onGameStart();

		//setup automatic beat, step and section updates
		gameplayStuff.Conductor.setupUpdates();
	}

	static final ERROR_REPORT_URL = "https://github.com/AltronMaxX/FNF-AltronixEngine";

	/**
	 * Called when OpenFL encounters an uncaught fatal error.
	 * Note that the default logging system should NOT be used here in case that was the problem.
	 * @param error The error that was thrown.
	 */
	public static function onUncaughtError(error:UncaughtErrorEvent)
	{
		#if FEATURE_FILESYSTEM

		var errorMsg:String = '';

		var funnyTitle:Array<String> = 
		[
			'Fatal Error!',
			'Monika deleted everything!',
			'Catastrophic Error',
			'Well-well-well, what have we got here?',
			'Game over',
			'Kade Engine moment',
			'Tester couldn`t find it'
		];

		errorMsg += '==========FATAL ERROR==========\n';
		errorMsg += 'An uncaught error was thrown, and the game had to close.\n';
		errorMsg += 'Please use the link below, create a new issue, and upload this file to report the error.\n';
		errorMsg += '\n';
		errorMsg +=  ERROR_REPORT_URL;
		errorMsg += '\n';

		errorMsg += '==========SYSTEM INFO==========\n';
		errorMsg += 'Altronix Engine version: ${EngineConstants.engineVer}\n';
		errorMsg += '  HaxeFlixel version: ${Std.string(FlxG.VERSION)}\n';
		errorMsg += '  Friday Night Funkin\' version: ${states.MainMenuState.gameVer}\n';
		errorMsg += 'System telemetry:\n';
		errorMsg += '  OS: ${Capabilities.os}\n';

		errorMsg += '\n';

		errorMsg += '==========STACK TRACE==========\n';
		errorMsg += error.error + '\n';

		var errorCallStack:Array<StackItem> = CallStack.exceptionStack(true);

		for (line in errorCallStack)
		{
			switch (line)
			{
				case CFunction:
					errorMsg += '  function:\n';
				case Module(m):
					errorMsg += '  module:${m}\n';
				case FilePos(s, file, line, column):
					errorMsg += '  (${file}#${line},${column})\n';
				case Method(className, method):
					errorMsg += '  method:(${className}/${method}\n';
				case LocalFunction(v):
					errorMsg += '  localFunction:${v}\n';
				default:
					Sys.println(line);
			}
		}
		errorMsg += '\n';

		var logFolderPath = CoolUtil.createDirectoryIfNotExists('crashes');

		var path:String = '${logFolderPath}/Altronix Engine - ${DebugLogWriter.getDateString()}.crash';

		sys.io.File.saveContent(path, errorMsg + "\n");

		errorMsg += 'An error has occurred and the game is forced to close.\nPlease access the "crash" folder and send the .crash file to the developers:\n'
			+ ERROR_REPORT_URL +'\n';

		Application.current.window.alert('An error has occurred and the game is forced to close.\nPlease access the "crash" folder and send the .crash file to the developers:\n' + ERROR_REPORT_URL, funnyTitle[FlxG.random.int(0, funnyTitle.length - 1)]);

		Sys.println(errorMsg);

		#if sys
		Sys.exit(1);
		#end
		#else
		Application.current.window.alert('An error has occurred and the game is forced to close.\nWe cannot write a log file though. Tell the developers:\n'
			+ ERROR_REPORT_URL,
			funnyTitle[FlxG.random.int(0, funnyTitle.length - 1)]);
		#end
	}

	var game:FlxGame;

	var fpsCounter:EngineFPS;

	// taken from forever engine, cuz optimization very pog.
	// thank you shubs :)
	public static function dumpCache()
	{
		///* SPECIAL THANKS TO HAYA
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null)
			{
				Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}
		Assets.cache.clear("songs");
		// */
	}

	public function toggleFPS(fpsEnabled:Bool):Void
	{
	}

	public function changeFPSColor(color:FlxColor)
	{
		fpsCounter.textColor = color;
	}

	public function setFPSCap(cap:Float)
	{
		openfl.Lib.current.stage.frameRate = cap;
	}

	public function getFPSCap():Float
	{
		return openfl.Lib.current.stage.frameRate;
	}

	public function getFPS():Float
	{
		return fpsCounter.currentFPS;
	}
}
