package;

/**
 * ...
 * @author Kaelan
 */
class PixelColor 
{
	//these two variables are to never be touched. They store the original color value so adjustments can be retained.
	public var argb(default, null):Int;
	
	//Work values
	var _a:Int;
	var _r:Int;
	var _g:Int;
	var _b:Int;
	
	public var alpha(get, set):Int;
	public var red(get, set):Int;
	public var green(get, set):Int;
	public var blue(get, set):Int;
	
	public var alphaMultiplier:Float = 1;
	public var redMultiplier:Float = 1;
	public var greenMultiplier:Float = 1;
	public var blueMultiplier:Float = 1;
	
	public function new(_argb:Int) 
	{
		argb = _argb;
		
		_a = _argb >> 24;
		_r = (_argb >> 16) & 0xFF;
		_g = (_argb >> 8) & 0xFF;
		_b = _argb & 0xFF;
	}
	
	public function reset() {
		_a = argb >> 24;
		_r = (argb >> 16) & 0xFF;
		_g = (argb >> 8) & 0xFF;
		_b = argb & 0xFF;
	}
	
	public function invertHue() {
		var c = Std.int(((Math.max(red, Math.max(green, blue)) + Math.min(red, Math.min(green, blue)))));
		red = c - red;
		green = c - green;
		blue = c - blue;
	}
	public function invertLuminance() {
		
	}
	public function invertAlpha() {
		alpha = 255 - alpha;
	}

	public function getColorARGB():Int {
		return alpha << 24 | red << 16 | green << 8 | blue;
	}
	public function getColorRGB():Int {
		return red << 16 | green << 8 | blue;
	}
	
	function get_alpha():Int {
		var value:Float = _a;
		value *= alphaMultiplier;
		return Std.int(value);
	}
	function get_red():Int {
		var value:Float = _r;
		value *= redMultiplier;
		return Std.int(value);
	}
	function get_green():Int {
		var value:Float = _g;
		value *= greenMultiplier;
		return Std.int(value);
	}
	function get_blue():Int {
		var value:Float = _b;
		value *= blueMultiplier;
		return Std.int(value);
	}
	
	function set_alpha(_v:Int):Int {
		return _a = _v;
	}
	function set_red(_v:Int):Int {
		return _r = _v;
	}
	function set_green(_v:Int):Int {
		return _g = _v;
	}
	function set_blue(_v:Int):Int {
		return _b = _v;
	}
}