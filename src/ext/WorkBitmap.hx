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
	public var work:BitmapData;
	public var hex:Map<String, PixelColor>;
	public var display:BitmapData;
	
	public var alpha_max(null, set):Int;
	public var alpha_min(null, set):Int;
	
	var w_width:Int;
	var w_height:Int;
	public function new(_source:BitmapData, _width:Int, _height:Int) 
	{
		super();
		
		source = new Bitmap(_source);
		work = _source;
		
		w_width = _width;
		w_height = _height;
		
		hex = new Map();
		for (w in 0...w_width) {
			for (h in 0...w_height) {
				var place:String = "x" + w + "y" + h;
				hex[place] = new PixelColor(source.bitmapData.getPixel32(w, h), w, h);
			}
		}
		
		display = work;
		this.bitmapData = display;
	}
	public function reset() {
		work = source.bitmapData;
		hex = new Map();
		for (w in 0...w_width) {
			for (h in 0...w_height) {
				var place:String = "x" + w + "y" + h;
				hex[place] = new PixelColor(source.bitmapData.getPixel32(w, h), w, h);
			}
		}
		display = source.bitmapData;
		this.bitmapData = display;
	}
	
	function update_work() {
		for (a in hex) {
			work.setPixel32(a.x, a.y, a.argb);
		}
		
		update_display();
	}
	
	function update_display() {
		this.bitmapData = work;
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
	public function retroApply() {
		for (a in hex) {
			work.setPixel32(a.x, a.y, a.argb);
		}
		source = new Bitmap(work);
		display = work;
		this.bitmapData = display;
	}
}