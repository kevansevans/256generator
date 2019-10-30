package ext;

import openfl.display.Bitmap;
import openfl.display.BitmapData;

/**
 * ...
 * @author Kaelan
 */
class WorkBitmap extends Bitmap
{
	public var source:Bitmap;
	public var hex:Map<String, PixelColor>;
	
	public var alpha_max(null, set):Int;
	public var alpha_min(null, set):Int;
	
	public var hue_modifier(null, set):Float;
	public var sat_modifier(null, set):Float;
	public var lum_modifier(null, set):Float;
	
	var w_width:Int;
	var w_height:Int;
	public function new(_source:BitmapData, ?_width:Int, ?_height:Int) 
	{
		super();
		
		source = new Bitmap(_source);
		
		w_width = _width == null ? source.bitmapData.width : _width;
		w_height = _height == null ? source.bitmapData.height : _height;
		
		hex = new Map();
		for (w in 0...w_width) {
			for (h in 0...w_height) {
				var place:String = "x" + w + "y" + h;
				hex[place] = new PixelColor(source.bitmapData.getPixel32(w, h), w, h);
			}
		}
		
		bitmapData = source.bitmapData;
	}
	public function reset() {
		hex = new Map();
		for (w in 0...w_width) {
			for (h in 0...w_height) {
				var place:String = "x" + w + "y" + h;
				hex[place] = new PixelColor(source.bitmapData.getPixel32(w, h), w, h);
			}
		}
		for (a in hex) {
			bitmapData.setPixel32(a.x, a.y, a.argb);
		}
	}
	public function update() {
		for (a in hex) {
			bitmapData.setPixel32(a.x, a.y, a.argb);
		}
	}
	
	function set_alpha_max(value:Int):Int 
	{
		for (a in hex) {
			if (a.alpha > value) a.alpha = value;
		}
		return alpha_max = value;
	}
	
	function set_alpha_min(value:Int):Int 
	{
		for (a in hex) {
			if (a.alpha < value) a.alpha = value;
		}
		return alpha_min = value;
	}
	
	public function clear() {
		var empty_bitmap = new BitmapData(w_width, w_height, true, 0);
		this.bitmapData = empty_bitmap;
	}
	
	function set_hue_modifier(value:Float):Float
	{
		for (a in hex) {
			a.hue = value;
		}
		return hue_modifier = value;
	}
	
	function set_sat_modifier(value:Float):Float 
	{
		for (a in hex) {
			a.saturation = value;
		}
		return sat_modifier = value;
	}
	
	function set_lum_modifier(value:Float):Float 
	{
		for (a in hex) {
			a.luminance = value;
		}
		return lum_modifier = value;
	}
}