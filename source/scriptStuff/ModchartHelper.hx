package scriptStuff;

import gameplayStuff.Boyfriend;
import gameplayStuff.Character;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import Paths;
import scriptStuff.ScriptHelper;
import states.PlayState;
import openfl.utils.Assets;
import gameplayStuff.FunkinLua;

@:access(states.PlayState)
class ModchartHelper extends FlxTypedGroup<FlxBasic>
{
	public var scriptHelper:ScriptHelper;
	var playState:PlayState;
	
	var cachedChars:Map<String, Character> = [];
	var cachedBFs:Map<String, Boyfriend> = [];

	public function new(path:String, state:PlayState)
	{
		super();
		
		this.playState = state;

		if (scriptHelper == null)
			scriptHelper = new ScriptHelper();

		if (!scriptHelper.expose.exists("PlayState"))
			scriptHelper.expose.set("PlayState", playState);
		
		if (playState.hscriptStage != null){
			if (!scriptHelper.expose.exists("stage"))
				scriptHelper.expose.set("stage", playState.hscriptStage);}
		
		if (!scriptHelper.expose.exists("gf") && playState.gf != null)
			scriptHelper.expose.set("gf", playState.gf);
		if (!scriptHelper.expose.exists("dad") && playState.dad != null)
			scriptHelper.expose.set("dad", playState.dad);
		if (!scriptHelper.expose.exists("boyfriend") && playState.boyfriend != null)
			scriptHelper.expose.set("boyfriend", playState.boyfriend);

		if (!scriptHelper.expose.exists("gfGroup") && playState.gfGroup != null)
			scriptHelper.expose.set("gfGroup", playState.gfGroup);
		if (!scriptHelper.expose.exists("dadGroup") && playState.dadGroup != null)
			scriptHelper.expose.set("dadGroup", playState.dadGroup);
		if (!scriptHelper.expose.exists("boyfriendGroup") && playState.boyfriendGroup != null)
			scriptHelper.expose.set("boyfriendGroup", playState.boyfriendGroup);

		scriptHelper.expose.set("curBeat", 0);
		scriptHelper.expose.set("curStep", 0);
		scriptHelper.expose.set("curSectionNumber", 0);

		scriptHelper.expose.set("setOnHscript", playState.setOnHscript);
		scriptHelper.expose.set("callOnHscript", playState.callOnHscript);

		scriptHelper.expose.set("setOnLuas", playState.setOnLuas);
		scriptHelper.expose.set("callOnLuas", playState.callOnLuas);

		scriptHelper.expose.set("camGame", playState.camGame);
		scriptHelper.expose.set("camHUD", playState.camHUD);
		scriptHelper.expose.set("enemyStrumLine", playState.opponentStrums);
		scriptHelper.expose.set("playerStrumLine", playState.playerStrums);
		scriptHelper.expose.set("cacheCharacter", cacheCharacter);
		scriptHelper.expose.set("changeCharacter", changeCharacter);

		scriptHelper.expose.set("setObjectCam", setObjectCam);

		scriptHelper.loadScript(path);

		if (scriptHelper.get("onCreate") != null)
			scriptHelper.get("onCreate")();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (scriptHelper.get("onUpdate") != null)
			scriptHelper.get("onUpdate")(elapsed);
	}

	public function changeCharacter(tag:String = 'bf', charName:String = 'bf')
	{
		if (tag == 'bf')
		{
			if (cachedBFs.get(charName) != null)
			{
				PlayState.instance.changeCharacterToCached(tag, cachedBFs.get(charName));
			}
			else
			{
				Debug.logError('This character not cached');
				return;
			}
		}
		else
		{
			if (cachedChars.get(charName) != null)
			{
				PlayState.instance.changeCharacterToCached(tag, cachedChars.get(charName));
			}
			else
			{
				Debug.logError('This character not cached');
				return;
			}
		}	
	}

	public function cacheCharacter(x:Float = 0, y:Float = 0, charName:String = 'bf', charType:String = 'bf')
	{
		if (charType == 'bf')
		{
			var newChar:Boyfriend = new Boyfriend(x, y, charName);
			cachedBFs.set(charName, newChar);

			if (cachedBFs.get(charName) == null)
			{
				Debug.logError('Error with character caching $charName');
				cachedBFs.remove(charName);
				return;
			}
		}
		else
		{
			var newChar:Character = new Character(x, y, charName);
			cachedChars.set(charName, newChar);

			if (cachedChars.get(charName) == null)
			{
				Debug.logError('Error with character caching $charName');
				cachedChars.remove(charName);
				return;
			}
		}	
	}

	public function startLuaScript(scriptName:String) //In Psych Engine you can start hscript from lua, but in Altronix we have another rules XD
	{
		if (Assets.exists('assets/scripts/$scriptName.lua'))
		{
			playState.luaArray.push(new FunkinLua(Assets.getPath('assets/scripts/$scriptName.lua')));
		}
	}

	public function getCameraFromString(camera:String):FlxCamera{
		switch (camera.toLowerCase())
		{
			case 'camhud' | 'hud':
				return PlayState.instance.camHUD;
			case 'camsustains' | 'sustains':
				return PlayState.instance.camSustains;
			case 'camnotes' | 'notes':
				return PlayState.instance.camNotes;
		}
		return PlayState.instance.camGame;
	}

	public function setObjectCam(object:FlxBasic, camera:String)
	{
		if (object != null)
		{
			object.cameras = [getCameraFromString(camera)];
		}
	}

	public function opponentNoteHit(noteIndex:Float, noteData:Float, noteType:String, sustainNote:Bool)
	{
		if (scriptHelper.get("opponentNoteHit") != null)
			scriptHelper.get("opponentNoteHit")(noteIndex, noteData, noteType, sustainNote);
	}

	public function goodNoteHit(noteIndex:Float, noteData:Float, noteType:String, sustainNote:Bool)
	{
		if (scriptHelper.get("goodNoteHit") != null)
			scriptHelper.get("goodNoteHit")(noteIndex, noteData, noteType, sustainNote);
	}

	public function onBeat(beat:Int)
	{
		if (scriptHelper.get("onBeat") != null)
			scriptHelper.get("onBeat")(beat);
	}

	public function onStep(step:Int)
	{
		if (scriptHelper.get("onStep") != null)
			scriptHelper.get("onStep")(step);
	}

	public function onSectionHit()
	{
		if (scriptHelper.get("onSectionHit") != null)
			scriptHelper.get("onSectionHit")();
	}

	public function onCreatePost()
	{
		if (scriptHelper.get("onCreatePost") != null)
			scriptHelper.get("onCreatePost")();
	}

	public function onCountdownStarted()
	{
		if (scriptHelper.get("onCountdownStarted") != null)
			scriptHelper.get("onCountdownStarted")();
	}

	public function onStartCountdown()
	{
		if (scriptHelper.get("onStartCountdown") != null)
			scriptHelper.get("onStartCountdown")();
	}

	public function onSongStart()
	{
		if (scriptHelper.get("onSongStart") != null)
			scriptHelper.get("onSongStart")();
	}

	public function onResume()
	{
		if (scriptHelper.get("onResume") != null)
			scriptHelper.get("onResume")();
	}

	public function onPause()
	{
		if (scriptHelper.get("onPause") != null)
			scriptHelper.get("onPause")();
	}

	public function onGameOver()
	{
		if (scriptHelper.get("onGameOver") != null)
			scriptHelper.get("onGameOver")();
	}

	public function onEndSong()
	{
		if (scriptHelper.get("onEndSong") != null)
			scriptHelper.get("onEndSong")();
	}

	public function onAttack()
	{
		if (scriptHelper.get("onAttack") != null)
			scriptHelper.get("onAttack")();
	}

	public function onRecalculateRating()
	{
		if (scriptHelper.get("onRecalculateRating") != null)
			scriptHelper.get("onRecalculateRating")();
	}

	public function onMoveCamera(character:String)
	{
		if (scriptHelper.get("onMoveCamera") != null)
			scriptHelper.get("onMoveCamera")(character);
	}

	public function onCountdownTick(tick:Int)
	{
		if (scriptHelper.get("onCountdownTick") != null)
			scriptHelper.get("onCountdownTick")(tick);
	}

	public function onKeyRelease(key:String)
	{
		if (scriptHelper.get("onKeyRelease") != null)
			scriptHelper.get("onKeyRelease")(key);
	}

	public function onKeyPress(key:String)
	{
		if (scriptHelper.get("onKeyPress") != null)
			scriptHelper.get("onKeyPress")(key);
	}

	public function noteMissPress(key:String)
	{
		if (scriptHelper.get("noteMissPress") != null)
			scriptHelper.get("noteMissPress")(key);
	}

	public function onSkipDialogue(count:Int)
	{
		if (scriptHelper.get("onSkipDialogue") != null)
			scriptHelper.get("onSkipDialogue")(count);
	}

	public function onNextDialogue(count:Int)
	{
		if (scriptHelper.get("onNextDialogue") != null)
			scriptHelper.get("onNextDialogue")(count);
	}

	public function onUpdatePost(elapsed:Float)
	{
		if (scriptHelper.get("onUpdatePost") != null)
			scriptHelper.get("onUpdatePost")(elapsed);
	}

	public function onEvent(eventType:String, value1:Dynamic, value2:Dynamic = '')
	{
		if (scriptHelper.get("onEvent") != null)
			scriptHelper.get("onEvent")(eventType, value1, value2);
	}

	public function noteMiss(noteIndex:Int, noteData:Int, noteType:String, susNote:Bool)
	{
		if (scriptHelper.get("noteMiss") != null)
			scriptHelper.get("noteMiss")(noteIndex, noteData, noteType, susNote);
	}

	public function onTick(tick:Int)
	{
		if (scriptHelper.get("onTick") != null)
			scriptHelper.get("onTick")(tick);
	}

	public function get(field:String):Dynamic
		return scriptHelper.get(field);

	public function set(field:String, value:Dynamic)
		scriptHelper.set(field, value);
}
