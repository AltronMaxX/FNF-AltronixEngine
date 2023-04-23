package macros;

class CheckHaxeVersion
{
	public static macro function checkHaxeVersion():haxe.macro.Expr.ExprOf<Int>
	{
		#if (haxe < "4.3.0")
		Context.fatalError("Your Haxe version is older than 4.3.0. Please install the latest version of Haxe!", Context.currentPos());
		#end
		return macro $v{Context.definedValue("haxe_ver")};
	}
}
