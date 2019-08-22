package;

import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import sys.FileSystem;
import sys.io.File;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.Assets;
import openfl.Lib;
import openfl.ui.MouseCursor;
import openfl.ui.Mouse;
import openfl.ui.Keyboard;

import haxe.ui.Toolkit;
import haxe.ui.components.OptionBox;
import haxe.ui.containers.TabView;
import haxe.ui.containers.ScrollView;
import haxe.ui.containers.Box;
import haxe.ui.containers.HBox;
import haxe.ui.containers.VBox;
import haxe.ui.components.Button;
import haxe.ui.containers.dialogs.Dialog;
import haxe.ui.containers.dialogs.MessageBox;
import haxe.ui.util.Color;
import haxe.ui.events.UIEvent;
import haxe.ui.components.CheckBox;
import haxe.ui.components.DropDown;
import haxe.ui.components.HorizontalProgress;
import haxe.ui.components.Image;
import haxe.ui.components.Label;
import haxe.ui.components.Progress;
import haxe.ui.components.HorizontalSlider;
import haxe.ui.components.TextField;
import haxe.ui.data.ArrayDataSource;
import haxe.ui.layouts.AbsoluteLayout;

import ext.PixelColor;
import ext.WorkBitmap;

/**
 * ...
 * @author Kevansevans
 * 
 * Thanks for checking out my program. Please check out the Readme for compiling instructions.
 * The UI is a custom made library I've been slowly working on over time to suit my personal needs. It's not recommended you fiddle with this part of the
 * source as it's not integral to the program over all. Feel free to ask for help if you need it.
 * 
 */
enum ExportMode {
	TEXTURE;
	SPRITE;
	ANIMDEF;
	ACTOR;
}
class Main extends Sprite 
{
	static var pal:Array<WorkBitmap>;
	static var pal_neg:Array<WorkBitmap>;
	static var hex:Array<Map<String, PixelColor>>;
	static var hex_neg:Array<Map<String, PixelColor>>;
	static var dummy_texture:Bitmap;
	static var pal_datasource:ArrayDataSource<String>;
	static var main_palette:WorkBitmap;
	static var random_index:Int = -1;
	static var monofade_index:Int = -1;
	
	var overlay_bitmap:WorkBitmap;
	var underlay_bitmap:WorkBitmap;
	var display_bitmap:WorkBitmap;
	
	var hue_negative:Bool = false;
	var alpha_knockout_min:Int = 0;
	var alpha_knockout_max:Int = 255;
	
	var underlay_update:Bool = false;
	var overlay_update:Bool = false;
	
	public function new() 
	{
		super();
		
		//Backend Initialize
		getPalAndColorLists(); //get palettes and index their colors
		
		var rng_date = Std.int(Date.now().getTime());
		overlay_bitmap = new WorkBitmap(Assets.getBitmapData("embed/texture.png"));
		underlay_bitmap = new WorkBitmap(new BitmapData(overlay_bitmap.bitmapData.width, overlay_bitmap.bitmapData.height, true, 0xFF000000));
		display_bitmap = new WorkBitmap(new BitmapData(overlay_bitmap.bitmapData.width, overlay_bitmap.bitmapData.height, true, 0));
		
		//Frontend Initialize
		init_ui();
		init_events();
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent) {
			//if (e.keyCode == Keyboard.SPACE) update_workBitmap();
		});
		
		stage.addEventListener(Event.ENTER_FRAME, function(e:Event) {
			cycle_colors();
		});
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
	//Frontend functions
	///////////////////////////////////////////////////////////////////////////////////////////////
	var main_tab:TabView;
	var palette_box:ScrollView;
	var overlay_box:ScrollView;
	var export_box:ScrollView;
	function init_ui() {
		Toolkit.init();
		
		main_tab = new TabView();
		addChild(main_tab);
		main_tab.x = main_tab.y = 10;
		main_tab.backgroundColor = Color.fromComponents(0x77, 0x77, 0x77, 256);
		
		palette_tab();
		overlay_tab();
		export_tab();
		
		workbench_ui();
		
		resize_ui();
	}
	var box_palprop:HBox;
	var box_palview:Box;
	var box_alphaview:VBox;
	var pal_dropdown:DropDown;
	var pal_contextbutton:Button;
	var pal_savemono:Button;
	var pal_monoedit:MessageBox;
	var pal_alphako_min:HorizontalSlider;
	var pal_alphako_max:HorizontalSlider;
	var mono_a:Int = 0xFFFFFF;
	var mono_b:Int = 0;
	function palette_tab() {
		palette_box = new ScrollView();
		palette_box.text = "Palette";
		main_tab.addComponent(palette_box);
		
		box_palprop = new HBox();
		box_palprop.width = 270;
		box_palprop.height = 30;
		palette_box.addComponent(box_palprop);
		
		pal_dropdown = new DropDown();
		pal_dropdown.dataSource = pal_datasource;
		box_palprop.addComponent(pal_dropdown);
		pal_dropdown.selectedIndex = 0;
		pal_dropdown.text = "265 Colors";
		pal_dropdown.width = 150;
		pal_dropdown.dropdownHeight = 200;
		pal_dropdown.onChange = function(e:UIEvent) {
			underlay_update = true;
			if (contains(pal_monoedit)) removeChild(pal_monoedit);
			if (pal_dropdown.selectedIndex == random_index) {
				createRandomPal();
				pal_contextbutton.visible = true;
				pal_contextbutton.text = "Randomize";
				pal_contextbutton.onClick = function(e:UIEvent) {
					createRandomPal();
					resize_ui();
				};
			} else if (pal_dropdown.selectedIndex == monofade_index) {
				createMonofadePal(mono_a, mono_b);
				pal_contextbutton.visible = true;
				pal_contextbutton.text = "Edit";
				pal_contextbutton.onClick = function(e:UIEvent) {
					popup_monofade();
				};
			} else {
				update_mainPalette(pal_dropdown.selectedIndex);
				pal_contextbutton.visible = false;
			}
			resize_ui();
		}
		
		pal_contextbutton = new Button();
		box_palprop.addComponent(pal_contextbutton);
		pal_contextbutton.text = "I shouldn't be visible now";
		pal_contextbutton.width = 75;
		pal_contextbutton.visible = false;
		
		box_palview = new Box();
		palette_box.addComponent(box_palview);
		box_palview.width = box_palview.height = 275;
		
		box_palview.addChild(main_palette);
		main_palette.width = main_palette.height = 275;
		
		box_alphaview = new VBox();
		palette_box.addComponent(box_alphaview);
		
		var min_label:Label = new Label();
		box_alphaview.addComponent(min_label);
		min_label.text = "Alpha knockout minimum: None";
		
		pal_alphako_min = new HorizontalSlider();
		pal_alphako_min.min = -1;
		pal_alphako_min.max = 256;
		pal_alphako_min.value = -1;
		pal_alphako_min.width = 255;
		box_alphaview.addComponent(pal_alphako_min);
		pal_alphako_min.onChange = function(e:UIEvent) {
			underlay_update = true;
			alpha_knockout_min = Std.int(pal_alphako_min.value);
			min_label.text = "Alpha knockout minimum: " + (pal_alphako_min.value == -1 ? "None" : "" + Std.int(pal_alphako_min.value));
		}
		
		var max_label:Label = new Label();
		box_alphaview.addComponent(max_label);
		max_label.text = "Alpha knockout maximum: None";
		
		pal_alphako_max = new HorizontalSlider();
		pal_alphako_max.min = 0;
		pal_alphako_max.max = 256;
		pal_alphako_max.value = 256;
		pal_alphako_max.width = 255;
		box_alphaview.addComponent(pal_alphako_max);
		pal_alphako_max.onChange = function(e:UIEvent) {
			underlay_update = true;
			alpha_knockout_max = Std.int(pal_alphako_max.value);
			max_label.text = "Alpha knockout maximum: " + (pal_alphako_max.value == 256 ? "None" : "" + Std.int(pal_alphako_max.value));
		}
	}
	function popup_monofade() {
		pal_monoedit = new MessageBox();
		pal_monoedit.title = "Please input two RGB hex colors:";
		pal_monoedit.height = 160;
		pal_monoedit.closable = false;
		pal_monoedit.x = 320;
		pal_monoedit.y = 10;
		addChild(pal_monoedit);
		
		var colorbox:VBox = new VBox();
		var color_a:TextField = new TextField();
		var color_b:TextField = new TextField();
		pal_monoedit.addComponent(colorbox);
		color_a.text = StringTools.hex(mono_a, 6);
		color_b.text = StringTools.hex(mono_b, 6);
		colorbox.addComponent(color_a);
		colorbox.addComponent(color_b);
		
		var optionbox:HBox = new HBox();
		var save:Button = new Button();
		var quit:Button = new Button();
		pal_monoedit.addComponent(optionbox);
		save.text = "Save palette to disk";
		quit.text = "Close";
		optionbox.addComponent(save);
		optionbox.addComponent(quit);
		
		color_a.onChange = color_b.onChange = function(e:UIEvent) {
			var cola = Std.parseInt("0x" + color_a.text);
			var colb = Std.parseInt("0x" + color_b.text);
			if (cola == null || colb == null) return;
			createMonofadePal(cola, colb);
			mono_a = cola;
			mono_b = colb;
			underlay_update = true;
		}
		
		save.onClick = function(e:UIEvent) {
			var fout = File.write("img/" + StringTools.hex(Std.parseInt("0x" + color_a.text), 6) + " to " + StringTools.hex(Std.parseInt("0x" + color_b.text), 6) + ".png");
			var iout:ByteArray = main_palette.source.bitmapData.encode(new Rectangle(0, 0, 16, 16), new PNGEncoderOptions());
			fout.writeBytes(iout, 0, iout.length);
			fout.close();
			getPalAndColorLists();
			pal_dropdown.dataSource = pal_datasource;
		}
		
		quit.onClick = function(e:UIEvent) {
			removeChild(pal_monoedit);
		}
	}
	function createMonofadePal(_colA:Int = 0xFFFFFF, _colB:Int = 0) 
	{
		box_palview.removeChild(main_palette);
		var temp_bitmap:WorkBitmap = new WorkBitmap(monofade_palette(_colA, _colB), 16, 16);
		main_palette = temp_bitmap;
		box_palview.addChild(main_palette);
		resize_ui();
	}
	function createRandomPal() 
	{
		box_palview.removeChild(main_palette);
		var temp_bitmap:WorkBitmap = new WorkBitmap(random_palette(), 16, 16);
		main_palette = temp_bitmap;
		box_palview.addChild(main_palette);
	}
	
	var ov_alphamin_label:Label;
	var ov_alphamax_label:Label;
	var ov_alphamult_label:Label;
	var ov_alphamin_slider:HorizontalSlider;
	var ov_alphamax_slider:HorizontalSlider;
	var ov_alphamult_slider:HorizontalSlider;
	function overlay_tab() {
		overlay_box = new ScrollView();
		overlay_box.text = "Overlay";
		main_tab.addComponent(overlay_box);
	}
	
	var name_text:TextField;
	var sort_row:CheckBox;
	var sort_column:CheckBox;
	var export_progress:HorizontalProgress;
	function export_tab() {
		export_box = new ScrollView();
		export_box.text = "Export";
		main_tab.addComponent(export_box);
	}
	
	var workbench:Sprite;
	function workbench_ui() 
	{
		workbench = new Sprite();
		addChild(workbench);
		
		addChild(display_bitmap);
	}
	
	var buffer:Int = 0;
	var pal_posx:Int = 0;
	var pal_posy:Int = 0;
	function cycle_colors()
	{
		++buffer;
		if (buffer >= 10) {
			buffer = 0;
			var color = main_palette.bitmapData.getPixel32(pal_posx, pal_posy);
			for (a in underlay_bitmap.hex) {
				a.alpha = a.originalAlpha;
				a.red = (color >> 16) & 0xFF;
				a.green = (color >> 8) & 0xFF;
				a.blue = color & 0xFF;
			}
			++pal_posx;
			if (pal_posx >= 16) {
				pal_posx = 0;
				pal_posy += 1;
				if (pal_posy >= 16) pal_posy = 0;
			}
			underlay_update = true;
		}
		update_display();
	}
	
	function update_display() 
	{
		display_bitmap.clear();
		
		if (underlay_update) {
			for (a in underlay_bitmap.hex) {
				var place:String = "x" + a.x + "y" + a.y;
				if (overlay_bitmap.hex[place].originalAlpha >= alpha_knockout_max || overlay_bitmap.hex[place].originalAlpha <= alpha_knockout_min) a.alpha = 0;
				else a.alpha = 0xFF;
			}
			underlay_bitmap.update();
			underlay_update = false;
		}
		
		if (overlay_update) {
			
			overlay_update = false;
		}
		
		display_bitmap.bitmapData.draw(underlay_bitmap.bitmapData);
		display_bitmap.bitmapData.draw(overlay_bitmap.bitmapData);
	}
	function init_events() 
	{
		stage.addEventListener(Event.RESIZE, resize_ui);
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
	//Backend functions
	///////////////////////////////////////////////////////////////////////////////////////////////
	function resize_ui(?e:Event):Void 
	{
		main_tab.width = 300;
		main_tab.height = Lib.current.stage.stageHeight - 20;
		
		palette_box.width = main_tab.width - 10;
		palette_box.height = main_tab.height - 40;
		
		overlay_box.width = main_tab.width - 10;
		overlay_box.height = main_tab.height - 40;
		
		export_box.width = main_tab.width - 10;
		export_box.height = main_tab.height - 40;
		
		main_palette.width = main_palette.height = 275;
		
		workbench.x = 320;
		workbench.y = 40;
		workbench.graphics.clear();
		workbench.graphics.lineStyle(2, 0);
		workbench.graphics.beginBitmapFill(Assets.getBitmapData("embed/bg_fill.png"));
		workbench.graphics.moveTo(0, 0);
		workbench.graphics.lineTo(Lib.current.stage.stageWidth - 330, 0);
		workbench.graphics.lineTo(Lib.current.stage.stageWidth - 330, Lib.current.stage.stageHeight - 50);
		workbench.graphics.lineTo(0, Lib.current.stage.stageHeight - 50);
		workbench.graphics.lineTo(0, 0);
		
		display_bitmap.scaleX = display_bitmap.scaleY = 5;
		display_bitmap.x = (workbench.x + workbench.width / 2) - (display_bitmap.width / 2);
		display_bitmap.y = (workbench.y + workbench.height / 2) - (display_bitmap.height / 2);
	}
	inline public function update_mainPalette(_pal:Int = 0) {
		box_palview.removeChild(main_palette);
		if (!hue_negative) main_palette = pal[_pal];
		else if (hue_negative) main_palette = pal_neg[_pal];
		box_palview.addChild(main_palette);
	}
	function random_palette():BitmapData {
		var r_palette:BitmapData = new BitmapData(16, 16, false, 0);
		for (w in 0...r_palette.width) {
			for (h in 0...r_palette.height) {
				r_palette.setPixel(w, h, Std.int(Math.random() * 0xFFFFFF));
			}
		}
		return r_palette;
	}
	function monofade_palette(_colA:Int, _colB:Int):BitmapData {
		var r_range = (_colB >> 16) - (_colA >> 16);
		var g_range = ((_colB >> 8) & 0xFF) - ((_colA >> 8) & 0xFF);
		var b_range = (_colB & 0xFF) - (_colA & 0xFF);
		
		var r_step:Float = r_range == 0 ? 0 : r_range / 255;
		var g_step:Float = g_range == 0 ? 0 : g_range / 255;
		var b_step:Float = b_range == 0 ? 0 : b_range / 255;
		
		var r_value:Float = _colA >> 16;
		var g_value:Float = (_colA >> 8) & 0xFF;
		var b_value:Float = _colA & 0xFF;
		
		var bitmap:BitmapData = new BitmapData(16, 16, false, 0);
		
		for (h in 0...16) {
			for (w in 0...16) {
				if (h == 0 && w == 0) bitmap.setPixel(w, h, _colA);
				else if (h == 15 && w == 15) bitmap.setPixel(w, h, _colB);
				else {
					r_value += r_step;
					g_value += g_step;
					b_value += b_step;
					var color = Std.int(r_value) << 16 | Std.int(g_value) << 8 | Std.int(b_value);
					bitmap.setPixel(w, h, color);
				}
			}
		}
		
		return bitmap;
	}
	//Get palettes from assets
	static function getPalAndColorLists()
	{
		Main.pal = new Array();
		Main.pal_neg = new Array();
		var pal_names = FileSystem.readDirectory("img/");
		pal_datasource = new ArrayDataSource();
		
		var p_id:Int = 0;
		for (a in pal_names) {
			//grab image
			var t_bitmap = new Bitmap(BitmapData.fromBytes(File.getBytes("img/" + a)));
			
			//resize to 16 x 16
			var p_bitmap = new BitmapData(16, 16, true, 0xFFFFFFFF);
			p_bitmap.draw(t_bitmap);
			
			Main.pal[p_id] = new WorkBitmap(p_bitmap, 16, 16);
			
			for (b in Main.pal[p_id].hex) b.alpha = 0xFF;
			
			//create label for dropdown
			var l_text = StringTools.replace(a, ".png", "");
			l_text = StringTools.replace(l_text, ".jpg", "");
			l_text = StringTools.replace(l_text, "_", " ");
			pal_datasource.add(l_text);
			
			++p_id;
		}
		//Negative palettes
		p_id = 0;
		for (a in pal_names) {
			//grab image
			var t_bitmap = new Bitmap(BitmapData.fromBytes(File.getBytes("img/" + a)));
			
			//resize to 16 x 16
			var p_bitmap = new BitmapData(16, 16, false, 0xFFFFFFFF);
			p_bitmap.draw(t_bitmap);
			
			Main.pal_neg[p_id] = new WorkBitmap(p_bitmap, 16, 16);
			for (b in Main.pal_neg[p_id].hex) {
				b.invertHue();
				b.alpha = 0xFF;
			}
			
			++p_id;
		}
		main_palette = pal[0];
		
		random_index = pal_datasource.size;
		pal_datasource.add("Random 16 x 16");
		monofade_index = pal_datasource.size;
		pal_datasource.add("Mono-fade");
	}
}
