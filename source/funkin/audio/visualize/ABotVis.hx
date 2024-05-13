package funkin.audio.visualize;

import flixel.FlxSprite;
import flixel.addons.plugin.taskManager.FlxTask;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import funkin.audio.visualize.dsp.FFT;
import funkin.util.MathUtil;
import funkin.vis.audioclip.frontends.LimeAudioClip;
import funkin.vis.dsp.SpectralAnalyzer;

using Lambda;

class ABotVis extends FlxTypedSpriteGroup<FlxSprite>
{
  // public var vis:VisShit;
  var analyzer:SpectralAnalyzer;

  var volumes:Array<Float> = [];

  public var snd:FlxSound;

  public function new(snd:FlxSound)
  {
    super();

    this.snd = snd;

    // vis = new VisShit(snd);
    // vis.snd = snd;

    var visFrms:FlxAtlasFrames = Paths.getSparrowAtlas('aBotViz');

    // these are the differences in X position, from left to right
    var positionX:Array<Float> = [0, 59, 56, 66, 54, 52, 51];
    var positionY:Array<Float> = [0, -8, -3.5, -0.4, 0.5, 4.7, 7];

    for (lol in 1...8)
    {
      // pushes initial value
      volumes.push(0.0);
      var sum = function(num:Float, total:Float) return total += num;
      var posX:Float = positionX.slice(0, lol).fold(sum, 0);
      var posY:Float = positionY.slice(0, lol).fold(sum, 0);

      var viz:FlxSprite = new FlxSprite(posX, posY);
      viz.frames = visFrms;
      add(viz);

      var visStr = 'viz';
      viz.animation.addByPrefix('VIZ', visStr + lol, 0);
      viz.animation.play('VIZ', false, false, 6);
    }
  }

  public function initAnalyzer()
  {
    @:privateAccess
    analyzer = new SpectralAnalyzer(7, new LimeAudioClip(cast snd._channel.__source), 0.01, 30);
    analyzer.maxDb = -35;
    // analyzer.fftN = 2048;
  }

  var visTimer:Float = -1;
  var visTimeMax:Float = 1 / 30;

  override function update(elapsed:Float)
  {
    super.update(elapsed);
  }

  static inline function min(x:Int, y:Int):Int
  {
    return x > y ? y : x;
  }

  override function draw()
  {
    #if web
    if (analyzer != null) drawFFT();
    #end
    super.draw();
  }

  /**
   * TJW funkin.vis based visualizer! updateFFT() is the old nasty shit that dont worky!
   */
  function drawFFT():Void
  {
    var levels = analyzer.getLevels(false);

    for (i in 0...min(group.members.length, levels.length))
    {
      var animFrame:Int = Math.round(levels[i].value * 5);

      animFrame = Math.floor(Math.min(5, animFrame));
      animFrame = Math.floor(Math.max(0, animFrame));

      animFrame = Std.int(Math.abs(animFrame - 5)); // shitty dumbass flip, cuz dave got da shit backwards lol!

      group.members[i].animation.curAnim.curFrame = animFrame;
    }
  }
}
