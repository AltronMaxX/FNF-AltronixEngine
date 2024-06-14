package altronix.play.components;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import funkin.Highscore;
import funkin.Paths;
import funkin.Preferences;
import funkin.play.PlayState;

using StringTools;

class ScoreText extends FlxTypedGroup<FlxText>
{
  public var accuracyText:FlxText = new FlxText();
  public var missesText:FlxText = new FlxText();
  public var scoreText:FlxText = new FlxText();

  public var x(default, set):Float = 0;

  public var y(default, set):Float = 0;

  public var alpha(default, set):Float = 1.0;

  @:isVar
  public var width(get, null):Float;

  @:isVar
  public var height(get, null):Float;

  public var text(get, null):String;

  private var textColor(default, set):FlxColor = FlxColor.WHITE;

  private var missColorTween:FlxTween;

  public function new(x:Float = 0, y:Float = 0)
  {
    super();

    add(scoreText);
    if (Preferences.advancedScoreText)
    {
      add(missesText);
      add(accuracyText);
    }

    this.x = x;
    this.y = y;

    if (Preferences.advancedScoreText)
    {
      forEach(function(text:FlxText) {
        text.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        text.scrollFactor.set();
        text.cameras = [PlayState.instance.camHUD];
        text.zIndex = 851;
      });
    }
    else
    {
      scoreText.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
      scoreText.scrollFactor.set();
      scoreText.cameras = [PlayState.instance.camHUD];
      scoreText.zIndex = 851;
      scoreText.x += PlayState.instance.healthBarBG.width - 190;
    }

    updateYPosition(y);

    updateTexts();

    if (Preferences.advancedScoreText) screenCenter(X);
  }

  // Update texts info
  public function updateTexts():Void
  {
    if (Preferences.advancedScoreText)
    {
      scoreText.text = 'Score: ${PlayState.instance.songScore} | ';

      missesText.text = 'Misses: ${Highscore.tallies.missed} | ';

      accuracyText.text = PlayState.instance.isBotPlayMode ? "BOTPLAY" : 'Accuracy: ${floatToStringPrecision(PlayState.instance.accuracy, 2)}% '
        + '(${generateAccuracyRank(PlayState.instance.accuracy)})';

      updateXPosition(x);

      if (textColor != getTextColor(PlayState.instance.accuracy) && PlayState.instance.accuracy >= 0)
      {
        textColor = getTextColor(PlayState.instance.accuracy);
      }
    }
    else
    {
      if (PlayState.instance.isBotPlayMode)
      {
        scoreText.text = 'Bot Play Enabled';
      }
      else
      {
        scoreText.text = 'Score:' + PlayState.instance.songScore;
      }
    }
  }

  // Flick misses counter color to red
  public function onMiss():Void
  {
    if (Preferences.advancedScoreText)
    {
      missColorTween = FlxTween.tween(missesText, {color: FlxColor.RED}, 0.1,
        {
          onComplete: function(twn:FlxTween) {
            missColorTween = FlxTween.tween(missesText, {color: textColor}, 0.1,
              {
                onComplete: function(twn:FlxTween) {
                  missColorTween = null;
                  updateColor(textColor);
                }
              });
          }
        });
    }
  }

  function floatToStringPrecision(n:Float, prec:Int):String
  {
    n = Math.round(n * Math.pow(10, prec));
    var str = '' + n;
    var len = str.length;
    if (len <= prec)
    {
      while (len < prec)
      {
        str = '0' + str;
        len++;
      }
      return '0.' + str;
    }
    else
    {
      return str.substr(0, str.length - prec) + '.' + str.substr(str.length - prec);
    }
  }

  function generateAccuracyRank(accuracy:Float):String
  {
    var rating = 'N/A';

    var wifeConditions:Array<Bool> = [
      accuracy >= 99.9935, // AAAAA
      accuracy >= 99.955, // AAAA
      accuracy >= 99.70, // AAA
      accuracy >= 93, // AA
      accuracy >= 80, // A
      accuracy >= 70, // B
      accuracy >= 60, // C
      accuracy < 60 // D
    ];

    for (i in 0...wifeConditions.length)
    {
      if (wifeConditions[i])
      {
        switch (i)
        {
          case 0:
            rating = "AAAAA";
          case 1:
            rating = "AAAA";
          case 2:
            rating = "AAA";
          case 3:
            rating = "AA";
          case 4:
            rating = "A";
          case 5:
            rating = "B";
          case 6:
            rating = "C";
          case 7:
            rating = "D";
        }
        break;
      }
    }

    return rating;
  }

  function getTextColor(accuracy:Float):FlxColor
  {
    var wifeConditions:Array<Bool> = [
      accuracy >= 80, // A - AAAAA
      accuracy >= 70, // B - A
      accuracy >= 60, // D - C
      accuracy < 60 && accuracy > 0, // D
      accuracy == 0 // Default
    ];

    for (i in 0...wifeConditions.length)
    {
      if (wifeConditions[i])
      {
        switch (i)
        {
          case 0:
            return FlxColor.fromString('0xFFD700');
          case 1:
            return FlxColor.fromString('0xADFF2F');
          case 2:
            return FlxColor.fromString('0xFF4500');
          case 3:
            return FlxColor.fromString('0x8B0000');
          case 4:
            return FlxColor.WHITE;
        }
        break;
      }
    }
    return FlxColor.WHITE;
  }

  function set_y(value:Float):Float
  {
    y = value;
    updateYPosition(y);
    return value;
  }

  function updateYPosition(value:Float):Void
  {
    forEach(function(text:FlxText) {
      text.y = value;
    });
  }

  function set_alpha(value:Float):Float
  {
    alpha = value;
    forEach(function(text:FlxText) {
      text.alpha = value;
    });
    return value;
  }

  // Centeres texts
  public inline function screenCenter(axes:FlxAxes = XY):ScoreText
  {
    if (axes.x) x = (FlxG.width - width) / 2;

    if (axes.y) y = (FlxG.height - height) / 2;

    return this;
  }

  function get_text():String
  {
    var retVal:String = '';
    forEach(function(text:FlxText) {
      retVal += text.text;
    });
    return retVal;
  }

  function get_width():Float
  {
    var returnVal:Float = 0;
    forEach(function(text:FlxText) {
      returnVal += text.width;
    });
    return returnVal;
  }

  function get_height():Float
  {
    return members[0].height; // all texts has same height lol
  }

  function set_x(value:Float):Float
  {
    x = value;
    updateXPosition(value);
    return value;
  }

  function updateXPosition(value:Float):Void
  {
    scoreText.x = value;
    missesText.x = scoreText.x + scoreText.width;
    accuracyText.x = missesText.x + missesText.width;
  }

  function updateColor(value:FlxColor):Void
  {
    forEach(function(text:FlxText) {
      if (text.text.startsWith('Misses') && missColorTween != null)
      {
        text.color = value;
      }
      else
      {
        text.color = value;
      }
    });
  }

  function set_textColor(value:FlxColor):FlxColor
  {
    textColor = value;
    updateColor(value);
    return value;
  }
}
