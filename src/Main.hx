package;

import components.HSlider;
import lime.system.System;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.utils.ByteArray;
import openfl.Assets;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.net.FileReference;
import openfl.net.FileFilter;
import openfl.display.PNGEncoderOptions;
#if sys
import sys.FileSystem;
import sys.io.FileOutput;
import sys.io.File;
#end

import components.CheckBox;
import components.IconButton;
import components.Label;

/**
 * ...
 * @author Kaelan
 */
class Main extends Sprite 
{
	var palette:BitmapData;
	var draw_over:Null<BitmapData> = null;
	public function new() 
	{
		super();
		
		Assets.loadLibrary("assets").onComplete(function(library) {
			this.launch();
		});
	}
	var xpos:Int = 0;
	var ypos:Int = 0;
	var work_bitmapdata:BitmapData = new BitmapData(16, 16);
	var final_bitmap:Bitmap = new Bitmap();
	var bmp_palette:Bitmap;
	var scale_slider:HSlider;
	var final_sprite:Sprite = new Sprite();
	var bmp_sprite:Sprite = new Sprite();
	
	function launch() {
		palette = Assets.getBitmapData("img/256original.png");
		
		bmp_palette = new Bitmap(palette);
		addChild(bmp_sprite);
		bmp_sprite.addChild(bmp_palette);
		bmp_sprite.scaleX = bmp_sprite.scaleY = 10;
		bmp_sprite.addEventListener(MouseEvent.CLICK, set_preview);
		
		addChild(final_sprite);
		final_sprite.addChild(final_bitmap);
		final_sprite.scaleX = final_sprite.scaleY = 5;
		final_sprite.x = 340;
		final_sprite.y = 30;
		final_sprite.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) {
			if (!hasEventListener(Event.ENTER_FRAME)) {
				addEventListener(Event.ENTER_FRAME, draw_preview);
			}
		});
		
		scale_slider = new HSlider(0.5, 15, 5);
		addChild(scale_slider);
		scale_slider.onChange = function() {
			final_sprite.scaleX = final_sprite.scaleY = scale_slider.value;
		}
		scale_slider.x = 340;
		scale_slider.y = 15;
		
		this.addEventListener(Event.ENTER_FRAME, draw_preview);
		
		make_ux();
	}
	var pal_256:CheckBox;
	var pal_doom:CheckBox;
	var pal_heretic:CheckBox;
	var pal_hexen:CheckBox;
	var pal_strife:CheckBox;
	var pal_quake:CheckBox;
	var cur_selected:CheckBox;
	
	var texname:Label;
	
	var drawover_colors:Map<String, Int>;
	var drawover_add:IconButton;
	var drawover_label:Label;
	var file_ref:FileReference;
	
	var export:IconButton;
	var export_label:Label;
	
	var alpha_selective:CheckBox;
	var alpha_slider:HSlider;
	
	var row_sort:CheckBox;
	var col_sort:CheckBox;
	function make_ux() 
	{
		
		pal_256 = new CheckBox("256 Colors", true);
		addChild(pal_256);
		pal_256.onChange = function() {
			cur_selected.set(false);
			pal_256.set(true);
			cur_selected = pal_256;
			palette = Assets.getBitmapData("img/256original.png");
			bmp_palette.bitmapData = palette;
		}
		pal_256.x = 170;
		pal_256.y = 10;
		cur_selected = pal_256;
		
		pal_doom = new CheckBox("Doom palette", false);
		addChild(pal_doom);
		pal_doom.onChange = function() {
			cur_selected.set(false);
			pal_doom.set(true);
			cur_selected = pal_doom;
			palette = Assets.getBitmapData("img/doom.png");
			bmp_palette.bitmapData = palette;
		}
		pal_doom.x = 170;
		pal_doom.y = 30;
		
		pal_heretic = new CheckBox("Heretic palette", false);
		addChild(pal_heretic);
		pal_heretic.onChange = function() {
			cur_selected.set(false);
			pal_heretic.set(true);
			cur_selected = pal_heretic;
			palette = Assets.getBitmapData("img/heretic.png");
			bmp_palette.bitmapData = palette;
		}
		pal_heretic.x = 170;
		pal_heretic.y = 50;
		
		pal_hexen = new CheckBox("Hexen palette", false);
		addChild(pal_hexen);
		pal_hexen.onChange = function() {
			cur_selected.set(false);
			pal_hexen.set(true);
			cur_selected = pal_hexen;
			palette = Assets.getBitmapData("img/hexen.png");
			bmp_palette.bitmapData = palette;
		}
		pal_hexen.x = 170;
		pal_hexen.y = 70;
		
		pal_strife = new CheckBox("Strife palette", false);
		addChild(pal_strife);
		pal_strife.onChange = function() {
			cur_selected.set(false);
			pal_strife.set(true);
			cur_selected = pal_strife;
			palette = Assets.getBitmapData("img/strife.png");
			bmp_palette.bitmapData = palette;
		}
		pal_strife.x = 170;
		pal_strife.y = 90;
		
		pal_quake = new CheckBox("Quake palette", false);
		addChild(pal_quake);
		pal_quake.onChange = function() {
			cur_selected.set(false);
			pal_quake.set(true);
			cur_selected = pal_quake;
			palette = Assets.getBitmapData("img/quake.png");
			bmp_palette.bitmapData = palette;
		}
		pal_quake.x = 170;
		pal_quake.y = 110;
		
		texname = new Label(LabelType.INPUT, "My New Texture Pack");
		addChild(texname);
		texname.x = 10;
		texname.y = 170;
		
		drawover_add = new IconButton("add");
		drawover_add.func_up = function(e:MouseEvent) {
			file_ref = new FileReference();
			file_ref.addEventListener(Event.COMPLETE, load_drawover);
			file_ref.addEventListener(Event.SELECT, function(e:Event) {
				file_ref.load();
			});
			file_ref.browse([new FileFilter("PNG images", "png")]);
		}
		addChild(drawover_add);
		drawover_add.x = 10;
		drawover_add.y = 210;
		
		drawover_label = new Label(LabelType.DYNAMIC, "Add overlay texture");
		addChild(drawover_label);
		drawover_label.x = 50;
		drawover_label.y = 210;
		
		row_sort = new CheckBox("Sort by row", false);
		row_sort.onChange = function(e:MouseEvent) {
			if (col_sort.value) col_sort.set(false);
		}
		addChild(row_sort);
		row_sort.x = 10;
		row_sort.y = 250;
		
		col_sort = new CheckBox("Sort by column", false);
		addChild(col_sort);
		col_sort.onChange = function(e:MouseEvent) {
			if (row_sort.value) row_sort.set(false);
		}
		col_sort.x = 10;
		col_sort.y = 270;
		
		export = new IconButton("yes");
		export.func_up = function(e:MouseEvent) {
			export_palette();
		}
		addChild(export);
		export.x = 10;
		export.y = 310;
		
		export_label = new Label(LabelType.DYNAMIC, "Generate!");
		addChild(export_label);
		export_label.x = 50;
		export_label.y = 310;
		
		alpha_slider = new HSlider(0, 200, 100, RoundMode.FLOOR);
		//addChild(alpha_slider);
		alpha_slider.onChange = function(e:MouseEvent) {
			for (a in 0...draw_over.width) {
				for (b in 0...draw_over.height) {
					var place = "x" + a + "y" + b;
					if (((drawover_colors[place] >> 24) & 0xFF) == 0xFF) continue;
					else {
						var color = drawover_colors[place];
						var alpha:Float = ((color >> 24) & 0xFF) * (alpha_slider.value / 100);
						var color_new = ((Std.int(alpha) & 0xFF) << 24) | (color & 0xFFFFFF);
						draw_over.setPixel32(a, b, color_new);
					}
				}
			}
		}
		alpha_slider.x = 10;
		alpha_slider.y = 290;
	}
	function load_drawover(e:Event):Void 
	{
		draw_over = BitmapData.fromBytes(file_ref.data);
		drawover_label.set(file_ref.name);
		
		drawover_colors = new Map();
		for (a in 0...draw_over.width) {
			for (b in 0...draw_over.height) {
				var place = "x" + a + "y" + b;
				drawover_colors[place] = draw_over.getPixel32(a, b);
			}
		}
		
		set_preview();
	}
	var palx:Int = 0;
	var paly:Int = 0;
	function set_preview(?e:MouseEvent):Void 
	{
		var pos:Point;
		var color:Int;
		if (e == null) {
			pos = new Point(palx, paly);
		} else {
			pos = new Point(bmp_palette.mouseX, bmp_palette.mouseY);
			palx = Std.int(pos.x);
			paly = Std.int(pos.y);
		}
		color = palette.getPixel(Std.int(pos.x), Std.int(pos.y));
		if (draw_over != null) {
			work_bitmapdata = new BitmapData(draw_over.width, draw_over.height, true, (0xFF << 24) | color);
			work_bitmapdata.draw(draw_over);
		} else {
			work_bitmapdata = new BitmapData(64, 64, false, color);
		}
		final_bitmap.bitmapData = work_bitmapdata;
		
		if (hasEventListener(Event.ENTER_FRAME)) {
			removeEventListener(Event.ENTER_FRAME, draw_preview);
		}
	}
	var delay:Int = 30;
	var delay_count:Int = 0;
	function draw_preview(e:Event):Void 
	{
		if (delay_count <= delay) {
			++delay_count;
			return;
		} else {
			delay_count = 0;
		}
		var color = palette.getPixel(xpos, ypos);
		if (draw_over != null) {
			work_bitmapdata = new BitmapData(draw_over.width, draw_over.height, true, (0xFF << 24) | color);
			work_bitmapdata.draw(draw_over);
		} else {
			work_bitmapdata = new BitmapData(64, 64, false, color);
		}
		++xpos;
		if (xpos > 15) {
			xpos = 0;
			++ypos;
			if (ypos > 15) {
				ypos = 0;
			}
		}
		final_bitmap.bitmapData = work_bitmapdata;
	}
	function export_palette() 
	{
		removeEventListener(Event.ENTER_FRAME, draw_preview);
		if (draw_over == null) return;
		var outname:String = file_ref.name.substr(0, 4);
		var intToHex:Array<String> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"];
		
		#if sys
		FileSystem.createDirectory("output/" + texname.value + "/");
		if (row_sort.value || col_sort.value) {
			for (a in intToHex) {
				FileSystem.createDirectory("output/" + texname.value + "/" + outname + "/" + a + "/");
			}
		}
		for (a in 0...16) {
			for (b in 0...16) {
				var color = palette.getPixel(a, b);
				var subpath = "";
				if (row_sort.value) subpath = "/" + intToHex[b] + "/";
				else if (col_sort.value) subpath = "/" + intToHex[a] + "/";
				work_bitmapdata = new BitmapData(draw_over.width, draw_over.height, true, (0xFF << 24) | color);
				work_bitmapdata.draw(draw_over);
				var pathname = "output/" + texname.value + "/" + outname + subpath + intToHex[a] + intToHex[b] + ".png";
				var bytes:ByteArray = work_bitmapdata.encode(new Rectangle(0, 0, work_bitmapdata.width, work_bitmapdata.height), new PNGEncoderOptions());
				var png_out:FileOutput = File.write(pathname);
				png_out.writeBytes(bytes, 0, bytes.length);
				png_out.close();
			}
		}
		System.openFile('output\\' + texname.value + '\\');
		#elseif js
		
		#end
		addEventListener(Event.ENTER_FRAME, draw_preview);
	}
}
