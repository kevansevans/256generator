package;

import lime.system.System;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.utils.ByteArray;
import openfl.Assets;
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
import components.HSlider;

/**
 * ...
 * @author Kevansevans
 * 
 * Thanks for checking out my program. Please check out the Readme for compiling instructions.
 * The UI is a custom made library I've been slowly working on over time to suit my personal needs. It's not recommended you fiddle with this part of the
 * source as it's not integral to the program over all. Feel free to ask for help if you need it.
 * 
 */
enum GamePalette {
	C256;
	DOOM;
	HERETIC;
	HEXEN;
	STRIFE;
	QUAKE;
}
class Main extends Sprite 
{
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Important variables
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Array
	var palette_colors:Map<String, PixelColor>;
	var drawover_colors:Map<String, PixelColor>;
	var workbmp_colors:Map<String, Int>;
	var intToHex:Array<String> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"];
	
	//Bool
	var cycle:Bool = true;
	var hue_inverted:Bool = false;
	var lum_inverted:Bool = false;
	//these are stupid but necesary
	var hue_256_inv:Bool = false;
	var hue_doom_inv:Bool = false;
	var hue_heretic_inv:Bool = false;
	var hue_hexen_inv:Bool = false;
	var hue_strife_inv:Bool = false;
	var hue_quake_inv:Bool = false;
	var lum_256_inv:Bool = false;
	var lum_doom_inv:Bool = false;
	var lum_heretic_inv:Bool = false;
	var lum_hexen_inv:Bool = false;
	var lum_strife_inv:Bool = false;
	var lum_quake_inv:Bool = false;
	
	//Bitmap
	var bg_fill:BitmapData;
	var bmp_palette:Bitmap;
	var draw_over:BitmapData;
	var final_bitmap:Bitmap = new Bitmap();
	var palette:BitmapData;
	var work_bitmapdata:BitmapData = new BitmapData(16, 16);
	
	//Sprite (Not a catch all, the class type)
	var bg_sprite:Sprite;
	var bmp_sprite:Sprite = new Sprite();
	var final_sprite:Sprite = new Sprite();
	
	//Checkbox
	var alpha_selective:CheckBox;
	var cur_selected:CheckBox;
	var col_sort:CheckBox;
	var pal_256:CheckBox;
	var pal_doom:CheckBox;
	var pal_heretic:CheckBox;
	var pal_hexen:CheckBox;
	var pal_strife:CheckBox;
	var pal_quake:CheckBox;
	var pal_invert_hue:CheckBox;
	var pal_invert_sat:CheckBox;
	var row_sort:CheckBox;
	var sprite_mode:CheckBox;
	
	//slider
	var alpha_slider:HSlider;
	var capalpha_slider:HSlider;
	var saturation_slider:HSlider;
	var scale_slider:HSlider;
	
	//Label
	var alpha_amount:Label;
	var drawover_label:Label;
	var export_label:Label;
	var saturation_label:Label;
	var texname:Label;
	
	//Butons
	var drawover_add:IconButton;
	var export:IconButton;
	
	//other
	var file_ref:FileReference;
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Entry
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	public function new() 
	{
		super();
		
		mouseEnabled = false;
		
		Assets.loadLibrary("assets").onComplete(function(library) {
			this.launch();
		});
	}
	function launch() {
		bg_fill = Assets.getBitmapData("embed/bg_fill.png");
		palette = Assets.getBitmapData("img/256original.png");
		
		set_palette_colors();
		
		make_ux();
		
		addEventListener(Event.ENTER_FRAME, draw_preview);
		
		Lib.current.stage.addEventListener(Event.RESIZE, resize);
	}
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Front end junk
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	function make_ux() 
	{
		bg_sprite = new Sprite();
		addChild(bg_sprite);
		
		bmp_palette = new Bitmap(palette);
		addChild(bmp_sprite);
		bmp_sprite.addChild(bmp_palette);
		bmp_sprite.scaleX = bmp_sprite.scaleY = 10;
		bmp_sprite.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) {
			palx = Std.int(bmp_palette.mouseX);
			paly = Std.int(bmp_palette.mouseY);
			cycle = false;
			needsToUpdate = true;
		});
		
		addChild(final_sprite);
		final_sprite.addChild(final_bitmap);
		final_sprite.scaleX = final_sprite.scaleY = 5;
		final_sprite.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) {
			cycle = true;
			needsToUpdate = true;
		});
		
		scale_slider = new HSlider(0.5, 15, 5, RoundMode.NONE);
		addChild(scale_slider);
		scale_slider.onChange = function() {
			final_sprite.scaleX = final_sprite.scaleY = scale_slider.value;
			draw_bg();
		}
		
		pal_256 = new CheckBox("256 Colors", true);
		addChild(pal_256);
		pal_256.onChange = function() {
			cur_selected.set(false);
			pal_256.set(true);
			if (cur_selected == pal_256) return;
			cur_selected = pal_256;
			palette = Assets.getBitmapData("img/256original.png");
			set_palette_colors();
			bmp_palette.bitmapData = palette;
			invert_hue(GamePalette.C256);
		}
		cur_selected = pal_256;
		
		pal_doom = new CheckBox("Doom palette", false);
		addChild(pal_doom);
		pal_doom.onChange = function() {
			cur_selected.set(false);
			pal_doom.set(true);
			if (cur_selected == pal_doom) return;
			cur_selected = pal_doom;
			palette = Assets.getBitmapData("img/doom.png");
			set_palette_colors();
			invert_hue(GamePalette.DOOM);
			bmp_palette.bitmapData = palette;
		}
		
		pal_heretic = new CheckBox("Heretic palette", false);
		addChild(pal_heretic);
		pal_heretic.onChange = function() {
			cur_selected.set(false);
			pal_heretic.set(true);
			if (cur_selected == pal_heretic) return;
			cur_selected = pal_heretic;
			palette = Assets.getBitmapData("img/heretic.png");
			set_palette_colors();
			invert_hue(GamePalette.HERETIC);
			bmp_palette.bitmapData = palette;
		}
		
		pal_hexen = new CheckBox("Hexen palette", false);
		addChild(pal_hexen);
		pal_hexen.onChange = function() {
			cur_selected.set(false);
			pal_hexen.set(true);
			if (cur_selected == pal_hexen) return;
			cur_selected = pal_hexen;
			palette = Assets.getBitmapData("img/hexen.png");
			set_palette_colors();
			invert_hue(GamePalette.HEXEN);
			bmp_palette.bitmapData = palette;
		}
		
		pal_strife = new CheckBox("Strife palette", false);
		addChild(pal_strife);
		pal_strife.onChange = function() {
			cur_selected.set(false);
			pal_strife.set(true);
			if (cur_selected == pal_strife) return;
			cur_selected = pal_strife;
			palette = Assets.getBitmapData("img/strife.png");
			set_palette_colors();
			invert_hue(GamePalette.STRIFE);
			bmp_palette.bitmapData = palette;
		}
		
		pal_quake = new CheckBox("Quake palette", false);
		addChild(pal_quake);
		pal_quake.onChange = function() {
			cur_selected.set(false);
			pal_quake.set(true);
			if (cur_selected == pal_quake) return;
			cur_selected = pal_quake;
			palette = Assets.getBitmapData("img/quake.png");
			set_palette_colors();
			invert_hue(GamePalette.QUAKE);
			bmp_palette.bitmapData = palette;
		}
		
		pal_invert_hue = new CheckBox("Invert hue", false);
		addChild(pal_invert_hue);
		pal_invert_hue.onChange = function(e:MouseEvent) {
			hue_inverted = !hue_inverted;
			invert_hue();
		}
		
		texname = new Label(LabelType.INPUT, "My New Texture Pack");
		addChild(texname);
		
		drawover_add = new IconButton("add");
		drawover_add.func_up = function(e:MouseEvent) {
			call_load_asset();
		}
		addChild(drawover_add);
		
		drawover_label = new Label(LabelType.DYNAMIC, "Add overlay texture");
		addChild(drawover_label);
		
		row_sort = new CheckBox("Sort by row", false);
		row_sort.onChange = function(e:MouseEvent) {
			if (col_sort.value) col_sort.set(false);
		}
		addChild(row_sort);
		
		col_sort = new CheckBox("Sort by column", false);
		addChild(col_sort);
		col_sort.onChange = function(e:MouseEvent) {
			if (row_sort.value) row_sort.set(false);
		}
		
		sprite_mode = new CheckBox("Sprite mode", false);
		addChild(sprite_mode);
		
		export = new IconButton("yes");
		export.func_up = function(e:MouseEvent) {
			step_export_pre();
		}
		addChild(export);
		
		export_label = new Label(LabelType.DYNAMIC, "Generate!");
		addChild(export_label);
		
		alpha_amount = new Label(LabelType.DYNAMIC, "Alpha: 100% Cap: 255");
		addChild(alpha_amount);
		
		alpha_selective = new CheckBox("Selective Alpha", false);
		addChild(alpha_selective);
		
		alpha_slider = new HSlider(0, 500, 100, RoundMode.FLOOR);
		addChild(alpha_slider);
		alpha_slider.onChange = function(e:MouseEvent) {
			update_drawover_alpha();
		}
		
		capalpha_slider = new HSlider(0, 255, 255, RoundMode.FLOOR);
		addChild(capalpha_slider);
		capalpha_slider.onChange = function(e:MouseEvent) {
			update_drawover_alpha();
		}
		
		saturation_label = new Label();
		saturation_label.value = "Saturation: 100%";
		//addChild(saturation_label);
		
		saturation_slider = new HSlider(0, 200, 100);
		saturation_slider.onChange = function(e:MouseEvent) {
			update_drawover_saturation();
			update_drawover_alpha();
		}
		//addChild(saturation_slider);
		
		prog_bar = new ProgressBar();
		
		resize();
		draw_bg();
	}
	function call_load_asset() 
	{
		#if sys
				file_ref = new FileReference();
				file_ref.addEventListener(Event.COMPLETE, load_drawover);
				file_ref.addEventListener(Event.SELECT, function(e:Event) {
					file_ref.load();
				});
				file_ref.browse([new FileFilter("PNG images", "png")]);
			#elseif js
				var input = js.Browser.document.createElement("input");
				input.style.visibility = "hidden"; //comment this to test
				input.setAttribute("type", "file");
				input.id = "browse";
				input.onclick = function(e) {
					e.cancelBubble = true;
					e.stopPropagation();
				}
				input.onchange = function() {
					untyped var file = input.files[0];
					var reader = new js.html.FileReader();
					reader.onload = function(evt) {
						var buffer:ArrayBuffer = cast(evt.target.result, ArrayBuffer);
						var array:ByteArray = ByteArray.fromArrayBuffer(buffer);
						js_load(array);
						js.Browser.document.body.removeChild(input);
					}
					reader.readAsArrayBuffer(file);
				}
				js.Browser.document.body.appendChild(input);
				input.click();
			#end
	}
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Back end junk
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	function set_palette_colors() {
		palette_colors = new Map();
		for (a in 0...16) {
			for (b in 0...16) {
				var place = "x" + a + "y" + b;
				palette_colors[place] = new PixelColor(palette.getPixel32(a, b));
			}
		}
	}
	function update_palette_colors() {
		for (a in 0...16) {
			for (b in 0...16) {
				var place = "x" + a + "y" + b;
				palette.setPixel32(a, b, palette_colors[place].getColorARGB());
			}
		}
	}
	function resize(?e:Event) {
		bmp_sprite.x = 10;
		bmp_sprite.y = 10;
		
		scale_slider.x = bmp_sprite.x + bmp_sprite.width + 170;
		scale_slider.y = 15;
		
		sprite_mode.x = scale_slider.x + scale_slider.width + 10;
		sprite_mode.y = 6;
		
		drawover_add.x = sprite_mode.x + sprite_mode.width + 10;
		drawover_add.y = 5;
		
		drawover_label.x = drawover_add.x + drawover_add.width + 5;
		drawover_label.y = drawover_label.y + 5;
		
		final_sprite.x = scale_slider.x;
		final_sprite.y = scale_slider.y + 25;
		
		bg_sprite.x = final_sprite.x;
		bg_sprite.y = final_sprite.y;
		
		pal_256.x = bmp_sprite.x + bmp_sprite.width + 10;
		pal_256.y = 10;
		
		pal_doom.x = pal_256.x;
		pal_doom.y = pal_256.y + 20;
		
		pal_heretic.x = pal_256.x;
		pal_heretic.y = pal_doom.y + 20;
		
		pal_hexen.x = pal_256.x;
		pal_hexen.y = pal_heretic.y + 20;
		
		pal_strife.x = pal_256.x;
		pal_strife.y = pal_hexen.y + 20;
		
		pal_quake.x = pal_256.x;
		pal_quake.y = pal_strife.y + 20;
		
		pal_invert_hue.x = 10;
		pal_invert_hue.y = bmp_sprite.y + bmp_sprite.height + 20;
		
		alpha_amount.x = 10;
		alpha_amount.y = pal_invert_hue.y + pal_invert_hue.height + 5;
		
		alpha_selective.x = 10;
		alpha_selective.y = alpha_amount.y + 30;
		
		alpha_slider.x = 10;
		alpha_slider.y = alpha_selective.y + 30;
		
		capalpha_slider.x = 10;
		capalpha_slider.y = alpha_slider.y + 20;
		
		saturation_label.x = 10;
		saturation_label.y = capalpha_slider.y + 15;
		
		saturation_slider.x = 10;
		saturation_slider.y = saturation_label.y + 35;
		
		export.x = 10;
		export.y = Lib.current.stage.stageHeight - export.height - 20;
		
		export_label.x = export.x + export.width;
		export_label.y = export.y + 5;
		
		col_sort.x = 10;
		col_sort.y = export.y - 20;
		
		row_sort.x = 10;
		row_sort.y = col_sort.y - 20;
		
		texname.x = 10;
		texname.y = row_sort.y - 40;
		
		prog_bar.x = 10;
		prog_bar.y = Lib.current.stage.stageHeight - 10;
	}
	function draw_bg() 
	{
		bg_sprite.graphics.clear();
		if (!sprite_mode.value) return;
		bg_sprite.graphics.beginBitmapFill(bg_fill, null, true);
		bg_sprite.graphics.moveTo(0, 0);
		bg_sprite.graphics.lineTo(0, final_sprite.height);
		bg_sprite.graphics.lineTo(final_sprite.width, final_sprite.height);
		bg_sprite.graphics.lineTo(final_sprite.width, 0);
		bg_sprite.graphics.lineTo(0, 0);
	}
	function invert_hue(?_pal:GamePalette) {
		//"What the fuck" - Duke Nukem
		switch (_pal) {
			case GamePalette.C256 :
				if (hue_inverted == hue_256_inv) return;
				else hue_256_inv = hue_inverted;
			case GamePalette.DOOM :
				if (hue_inverted == hue_doom_inv) return;
				else hue_doom_inv = hue_inverted;
			case GamePalette.HERETIC :
				if (hue_inverted == hue_heretic_inv) return;
				else hue_heretic_inv = hue_inverted;
			case GamePalette.HEXEN :
				if (hue_inverted == hue_hexen_inv) return;
				else hue_hexen_inv = hue_inverted;
			case GamePalette.STRIFE :
				if (hue_inverted == hue_strife_inv) return;
				else hue_strife_inv = hue_inverted;
			case GamePalette.QUAKE :
				if (hue_inverted == hue_quake_inv) return;
				else hue_quake_inv = hue_inverted;
			default :
				if (cur_selected == pal_256) {
					hue_256_inv = hue_inverted;
				}
				if (cur_selected == pal_doom) {
					hue_doom_inv = hue_inverted;
				}
				if (cur_selected == pal_heretic) {
					hue_heretic_inv = hue_inverted;
				}
				if (cur_selected == pal_hexen) {
					hue_hexen_inv = hue_inverted;
				}
				if (cur_selected == pal_strife) {
					hue_strife_inv = hue_inverted;
				}
				if (cur_selected == pal_quake) {
					hue_quake_inv = hue_inverted;
				}
		}
		for (a in palette_colors) {
			a.invertHue();
		}
		update_palette_colors();
		bmp_palette.bitmapData = palette;
	}
	function invert_luminance(?_pal:GamePalette) {
		switch (_pal) {
			case GamePalette.C256 :
				if (lum_inverted == lum_256_inv) return;
				else lum_256_inv = lum_inverted;
			case GamePalette.DOOM :
				if (lum_inverted == lum_doom_inv) return;
				else lum_doom_inv = lum_inverted;
			case GamePalette.HERETIC :
				if (lum_inverted == lum_heretic_inv) return;
				else lum_heretic_inv = lum_inverted;
			case GamePalette.HEXEN :
				if (lum_inverted == lum_hexen_inv) return;
				else lum_hexen_inv = lum_inverted;
			case GamePalette.STRIFE :
				if (lum_inverted == lum_strife_inv) return;
				else lum_strife_inv = lum_inverted;
			case GamePalette.QUAKE :
				if (lum_inverted == lum_quake_inv) return;
				else lum_quake_inv = lum_inverted;
			default :
				if (cur_selected == pal_256) {
					lum_256_inv = lum_inverted;
				}
				if (cur_selected == pal_doom) {
					lum_doom_inv = lum_inverted;
				}
				if (cur_selected == pal_heretic) {
					lum_heretic_inv = lum_inverted;
				}
				if (cur_selected == pal_hexen) {
					lum_hexen_inv = lum_inverted;
				}
				if (cur_selected == pal_strife) {
					lum_strife_inv = lum_inverted;
				}
				if (cur_selected == pal_quake) {
					lum_quake_inv = lum_inverted;
				}
		}
	}
	#if js
	function js_load(_byteArray:ByteArray) {
		var future = BitmapData.loadFromBytes(_byteArray);
		future.onComplete( function(image) 
		{
			draw_over = image;
			load_drawover();
		});
	}
	#end
	function load_drawover(?e:Event):Void 
	{
		if (e != null) {
			draw_over = BitmapData.fromBytes(file_ref.data);
			drawover_label.set(file_ref.name);
		}
		drawover_colors = new Map();
		for (a in 0...draw_over.width) {
			for (b in 0...draw_over.height) {
				var place = "x" + a + "y" + b;
				drawover_colors[place] = new PixelColor(draw_over.getPixel32(a, b));
			}
		}
	}
	var palx:Int = 0;
	var paly:Int = 0;
	
	var delay:Int = 30;
	var delay_count:Int = 0;
	
	var needsToUpdate:Bool = false;
	
	function draw_preview(e:Event):Void 
	{
		if (delay_count <= delay) {
			++delay_count;
		} else {
			delay_count = 0;
		}
		var color = palette.getPixel(palx, paly);
		if (draw_over != null) {
			work_bitmapdata = new BitmapData(draw_over.width, draw_over.height, true, (0xFF << 24) | color);
			work_bitmapdata.draw(draw_over);
			if (sprite_mode.value) {
				for (c in 0...work_bitmapdata.width) {
					for (d in 0...work_bitmapdata.height) {
						var place:String = "x" + c + "y" + d;
						if ((drawover_colors[place] >> 24) & 0xFF != 0) continue;
						else work_bitmapdata.setPixel32(c, d, 0x00000000);
					}
				}
			}
		} else {
			work_bitmapdata = new BitmapData(64, 64, false, color);
		}
		if (needsToUpdate) {
			workbmp_colors = new Map<String, Int>();
			for (a in 0...work_bitmapdata.width) {
				for (b in 0...work_bitmapdata.height) {
					var place = "x" + a + "y" + b;
					workbmp_colors[place] = work_bitmapdata.getPixel32(a, b);
				}
			}
			needsToUpdate = false;
		}
		if (cycle && delay_count == 0) {
			needsToUpdate = true;
			++palx;
			if (palx > 15) {
				palx = 0;
				++paly;
				if (paly > 15) {
					paly = 0;
				}
			}
		}
		draw_bg();
		final_bitmap.bitmapData = work_bitmapdata;
	}
	var expx:Int;
	var expy:Int;
	var outname:String;
	var subpath = "";
	var progress_needed:Int = 0;
	var progress:Int = 0;
	var prog_bar:ProgressBar;
	#if js
	var zip:ZipWriter;
	#end
	function step_export_pre() {
		if (draw_over == null) return;
		addChild(prog_bar);
		removeEventListener(Event.ENTER_FRAME, draw_preview);
		expx = expy = 0;
		progress = 0;
		#if sys
		outname = file_ref.name.substr(0, 4);
		FileSystem.createDirectory("output/" + texname.value + "/");
		if (row_sort.value || col_sort.value) {
			for (a in intToHex) {
				FileSystem.createDirectory("output/" + texname.value + "/" + outname + "/" + a + "/");
			}
		}
		#elseif js
		outname = texname.value.substr(0, 4);
		zip = new ZipWriter();
		#end
		addEventListener(Event.ENTER_FRAME, step_export);
	}
	function step_export(e:Event):Void 
	{
		//info gather
		var color = palette.getPixel(expx, expy);
		if (row_sort.value) subpath = "/" + intToHex[expy] + "/";
		else if (col_sort.value) subpath = "/" + intToHex[expx] + "/";
		var pathname = "output/" + texname.value + "/" + outname + subpath + intToHex[expx] + intToHex[expy] + ".png";
		work_bitmapdata = new BitmapData(draw_over.width, draw_over.height, true, (0xFF << 24) | color);
		work_bitmapdata.draw(draw_over);
		progress_needed = 256;
		
		//Core loop
		if (sprite_mode.value) {
			for (c in 0...work_bitmapdata.width) {
				for (d in 0...work_bitmapdata.height) {
					var place:String = "x" + c + "y" + d;
					if ((drawover_colors[place] >> 24) & 0xFF != 0) continue;
					else work_bitmapdata.setPixel32(c, d, 0x00000000);
				}
			}
		}
		
		//export
		
		var bytes:ByteArray = work_bitmapdata.encode(new Rectangle(0, 0, work_bitmapdata.width, work_bitmapdata.height), new PNGEncoderOptions());
		
		#if sys
		
		var png_out:FileOutput = File.write(pathname);
		png_out.writeBytes(bytes, 0, bytes.length);
		png_out.close();
		
		#elseif js
		
		zip.addBytes(bytes, intToHex[expx] + intToHex[expy] + ".png", true);
		
		#end
		
		++progress;
		
		//update loop
		prog_bar.update(progress, progress_needed);
		++expx;
		if (expx >= 16) {
			expx = 0;
			++expy;
			if (expy >= 16) { //when the loop finishes
				#if windows
				System.openFile('output\\' + texname.value + '\\');
				#elseif linux
				System.openFile('output/' + texname.value + '/');
				#elseif js
				zip.addBytes(bytes, "entry.png", true);
				var data = zip.finalize();
				file_ref = new FileReference();
				file_ref.save(data, texname.value + ".zip");
				#end
				removeChild(prog_bar);
				removeEventListener(Event.ENTER_FRAME, step_export);
				addEventListener(Event.ENTER_FRAME, draw_preview);
			}
		}
	}
}
class ProgressBar extends Sprite {
	public function new() {
		super();
	}
	public function update(_fill:Float, _max:Float) {
		var ratio:Float = _max / _fill;
		graphics.clear();
		graphics.lineStyle(4, 0x00FF00);
		graphics.moveTo(0, 0);
		graphics.lineTo((Lib.current.stage.stageWidth - 20) * (1 / ratio), 0);
		graphics.lineStyle(4, 0xFFFFFF);
		graphics.lineTo((Lib.current.stage.stageWidth - 20), 0);
	}
}
