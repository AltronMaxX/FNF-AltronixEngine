import flixel.FlxG;
import flixel.math.FlxMath;

//TODO Remove class due duplication by Util.hx
class HelperFunctions
{
	public static function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	public static function GCD(a, b)
	{
		return b == 0 ? FlxMath.absInt(a) : GCD(b, a % b);
	}
}
