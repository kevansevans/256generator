package ext;

/**
 * ...
 * @author Kaelan
 */
class PixelColor 
{
	public var argb(get, null):Int;
	public var rgb(get, null):Int;
	
	//Work values
	var _a:Int;
	var _r:Int;
	var _g:Int;
	var _b:Int;
	
	public var x:Int;
	public var y:Int;
	
	public var alpha(get, set):Int;
	public var red(get, set):Int;
	public var green(get, set):Int;
	public var blue(get, set):Int;
	public var hue(get, null):Int;
	//public var saturation(get, null):Int;
	//public var luminance(get, null):Int;
	public var max(get, null):Float;
	public var min(get, null):Float;
	
	public var originalAlpha(get, never):Int;
	public var originalRed(get, never):Int;
	public var originalBlue(get, never):Int;
	public var originalGreen(get, never):Int;
	
	public var alphaMultiplier:Float = 1;
	public var saturationMultiplier:Float = 1;
	public var redMultiplier:Float = 1;
	public var greenMultiplier:Float = 1;
	public var blueMultiplier:Float = 1;
	
	public function new(_argb:Int, _x:Int, _y:Int) 
	{
		argb = _argb;
		
		x = _x;
		y = _y;
		
		_a = (_argb >> 24) & 0xFF;
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
	public function invertSaturation() {
		
	}
	public function invertLuminance() {
		
	}
	public function invertAlpha() {
		alpha = 255 - alpha;
	}

	public function get_argb():Int {
		return alpha << 24 | red << 16 | green << 8 | blue;
	}
	public function get_rgb():Int {
		return red << 16 | green << 8 | blue;
	}
	
	function get_originalAlpha():Int {
		return (argb >> 24) & 0xFF;
	}
	function get_originalRed():Int {
		return (argb >> 16) & 0xFF;
	}
	function get_originalGreen():Int {
		return (argb >> 8) & 0xFF;
	}
	function get_originalBlue():Int {
		return argb & 0xFF;
	}
	
	function get_alpha():Int {
		var value:Float = _a;
		value *= alphaMultiplier;
		value *= saturationMultiplier;
		return Std.int(Math.min(value, 255)) & 0xFF;
	}
	function get_red():Int {
		var value:Float = _r;
		value *= redMultiplier;
		value *= saturationMultiplier;
		return Std.int(Math.min(value, 255)) & 0xFF;
	}
	function get_green():Int {
		var value:Float = _g;
		value *= greenMultiplier;
		value *= saturationMultiplier;
		return Std.int(Math.min(value, 255)) & 0xFF;
	}
	function get_blue():Int {
		var value:Float = _b;
		value *= blueMultiplier;
		value *= saturationMultiplier;
		return Std.int(Math.min(value, 255)) & 0xFF;
	}
	function get_max():Float {
		return Math.max(Math.max(red / 255, green / 255), blue / 255);
	}
	function get_min():Float {
		return Math.min(Math.min(red / 255, green / 255), blue / 255);
	}
	function get_hue():Int {
		var delta:Float = max - min;
		var hue:Float = 0;
		var r:Float = red / 255;
		var g:Float = green / 255;
		var b:Float = blue / 255;
		if (delta == 0) hue = 0;
		else {
			switch (max) {
				case r:
					hue = (((g - b) / 6) / delta);
				case g:
					hue = ((1 / 3) + ((b - r) / 6) / delta);
				case b:
					hue = ((2 / 3) + ((r - g) / 6) / delta);
			}
		}
		if (hue < 0) hue += 1;
		if (hue > 1) hue -= 1;
		hue *= 360;
		return Std.int(hue);
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