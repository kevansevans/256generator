package;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

import haxe.display.Display.PositionParams;
import haxe.ui.components.Slider;
import haxe.ui.components.Stepper;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
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
	static var hex:Array<Map<String, PixelColor>>;
	static var dummy_texture:Bitmap;
	static var pal_datasource:ArrayDataSource<String>;
	static var main_palette:WorkBitmap;
	static var random_index:Int = -1;
	static var monofade_index:Int = -1;
	static var swatcheToggle:Map<String, Bool>;
	
	var overlay_bitmap:WorkBitmap;
	var underlay_bitmap:WorkBitmap;
	var display_bitmap:WorkBitmap;
	var display_scale:Float = 5;
	
	var hue_negative:Bool = false;
	var alpha_knockout_min:Int = 0;
	var alpha_knockout_max:Int = 255;
	
	var underlay_update:Bool = false;
	var overlay_update:Bool = false;
	
	var origin:Point = new Point();
	var display_center:Point = new Point();
	
	public function new() 
	{
		super();
		
		//Backend Initialize
		getPalAndColorLists(); //get palettes and index their colors
		
		var rng_date = Std.int(Date.now().getTime());
		overlay_bitmap = new WorkBitmap(Assets.getBitmapData("embed/shirt.png"));
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
	var bitmap_scale:HorizontalSlider;
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
		
		update_origin(new Point(0, 0));
		
		bitmap_scale = new HorizontalSlider();
		addChild(bitmap_scale);
		bitmap_scale.x = workbench.x;
		bitmap_scale.y = workbench.y - 25;
		bitmap_scale.width = 300;
		bitmap_scale.min = 0.25;
		bitmap_scale.max = 15;
		bitmap_scale.value = 5;
		bitmap_scale.onChange = function(e:UIEvent) {
			display_scale = bitmap_scale.value;
			
			update_display_size();
			update_origin(origin);
		}
	}
	var box_palprop:HBox;
	var box_palview:Box;
	var box_alphaview_min:HBox;
	var box_alphaview_max:HBox;
	var box_HSLMain:VBox;
	var box_hue:HBox;
	var box_sat:HBox;
	var box_lum:HBox;
	var pal_dropdown:DropDown;
	var pal_contextbutton:Button;
	var pal_swatchSelectButton:Button;
	var pal_savemono:Button;
	var pal_monoedit:VBox;
	var pal_alphamin_step:Stepper;
	var pal_alphamin_field:TextField;
	var pal_alphamax_step:Stepper;
	var pal_alphamax_field:TextField;
	var pal_hueslider:HorizontalSlider;
	var pal_huelabel:Label;
	var pal_satslider:HorizontalSlider;
	var pal_satlabel:Label;
	var pal_lumslider:HorizontalSlider;
	var pal_lumlabel:Label;
	var mono_a:Int = 0xFFFFFF;
	var mono_b:Int = 0;
	var drawoverSwatches:Sprite = new Sprite();
	var range_box:Box;
	function palette_tab() {
		palette_box = new ScrollView();
		palette_box.text = "Under Color";
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
					pal_contextbutton.disabled = true;
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
		
		var alphaknockout_label:Label = new Label();
		palette_box.addComponent(alphaknockout_label);
		alphaknockout_label.text = "Alpha knockout";
		
		box_alphaview_min = new HBox();
		palette_box.addComponent(box_alphaview_min);
		
		pal_alphamin_field = new TextField();
		box_alphaview_min.addComponent(pal_alphamin_field);
		pal_alphamin_field.width = 100;
		pal_alphamin_field.text = "Off";
		pal_alphamin_field.onChange = function(e:UIEvent) {
			
			var value:Null<Int> = Std.parseInt(pal_alphamin_field.value);
			
			if (value != null) {
				alpha_knockout_min = value;
				pal_alphamin_step.value = value;
			} else {
				if (pal_alphamin_field.value.toUpperCase() == "OFF") alpha_knockout_min = -1;
				if (pal_alphamin_field.value.toUpperCase() == "FULL") alpha_knockout_min = 256;
			}
		}
		
		pal_alphamin_step = new Stepper();
		box_alphaview_min.addComponent(pal_alphamin_step);
		pal_alphamin_step.value = -1;
		pal_alphamin_step.max = 256;
		pal_alphamin_step.min = -1;
		pal_alphamin_step.onChange = function(e:UIEvent) {
			
			switch (pal_alphamin_step.value) {
				case -1 :
					pal_alphamin_field.text = "-1 Off";
					alpha_knockout_min = -1;
				case 256 :
					pal_alphamin_field.text = "256 Full";
					alpha_knockout_min = 256;
				default :
					pal_alphamin_field.text = pal_alphamin_step.value;
					alpha_knockout_min = pal_alphamin_step.value;
			}
			
			update_display();
		}
		
		var alphamin_label:Label = new Label();
		box_alphaview_min.addComponent(alphamin_label);
		alphamin_label.text = "Minimum alpha";
		
		box_alphaview_max = new HBox();
		palette_box.addComponent(box_alphaview_max);
		
		pal_alphamax_field = new TextField();
		box_alphaview_max.addComponent(pal_alphamax_field);
		pal_alphamax_field.width = 100;
		pal_alphamax_field.text = "Off";
		pal_alphamax_field.onChange = function(e:UIEvent) {
			
			var value:Null<Int> = Std.parseInt(pal_alphamax_field.value);
			
			if (value != null) {
				alpha_knockout_max = value;
				pal_alphamax_step.value = value;
			} else {
				if (pal_alphamax_field.value.toUpperCase() == "FULL") alpha_knockout_max = -1;
				if (pal_alphamax_field.value.toUpperCase() == "OFF") alpha_knockout_max = 256;
			}
		}
		
		pal_alphamax_step = new Stepper();
		box_alphaview_max.addComponent(pal_alphamax_step);
		pal_alphamax_step.value = 256;
		pal_alphamax_step.max = 256;
		pal_alphamax_step.min = -1;
		pal_alphamax_step.onChange = function(e:UIEvent) {
			
			switch (pal_alphamax_step.value) {
				case -1 :
					pal_alphamax_field.text = "-1 Full";
					alpha_knockout_max = -1;
				case 256 :
					pal_alphamax_field.text = "256 Off";
					alpha_knockout_max = 256;
				default :
					pal_alphamax_field.text = pal_alphamax_step.value;
					alpha_knockout_max = pal_alphamax_step.value;
			}
			
			update_display();
		}
		
		var alphamax_label:Label = new Label();
		box_alphaview_max.addComponent(alphamax_label);
		alphamax_label.text = "Maximum alpha";
		
		box_HSLMain = new VBox();
		palette_box.addComponent(box_HSLMain);
		
		var hsl_label:Label = new Label();
		box_HSLMain.addComponent(hsl_label);
		hsl_label.text = "HSL modifiers";
		
		box_hue = new HBox();
		box_HSLMain.addComponent(box_hue);
		
		pal_hueslider = new HorizontalSlider();
		pal_hueslider.width = 210;
		pal_hueslider.min = 0;
		pal_hueslider.max = 360;
		pal_hueslider.value = 180;
		pal_hueslider.onChange = function(e:UIEvent) {
			main_palette.hue_modifier = pal_hueslider.value - 180;
			if (Math.round(pal_hueslider.value) < 180) pal_huelabel.text = "Hue: " + Math.round(pal_hueslider.value - 180);
			else if (Math.round(pal_hueslider.value) > 180) pal_huelabel.text = "Hue: +" + Math.round(pal_hueslider.value - 180);
			else if (Math.round(pal_hueslider.value) == 180) pal_huelabel.text = "Hue: 0";
			main_palette.update();
		}
		box_hue.addComponent(pal_hueslider);
		
		pal_huelabel = new Label();
		box_hue.addComponent(pal_huelabel);
		
		box_sat = new HBox();
		box_HSLMain.addComponent(box_sat);
		
		pal_satslider = new HorizontalSlider();
		pal_satslider.width = 210;
		pal_satslider.min = 0;
		pal_satslider.max = 200;
		pal_satslider.value = 100;
		pal_satslider.onChange = function(e:UIEvent) {
			pal_satlabel.text = "Sat: " + Std.int(pal_satslider.value - 100);
			main_palette.sat_modifier = pal_satslider.value / 100;
			main_palette.update();
		}
		box_sat.addComponent(pal_satslider);
		
		pal_satlabel = new Label();
		box_sat.addComponent(pal_satlabel);
		
		box_lum = new HBox();
		box_HSLMain.addComponent(box_lum);
		
		pal_lumslider = new HorizontalSlider();
		pal_lumslider.width = 210;
		pal_lumslider.min = 0;
		pal_lumslider.max = 200;
		pal_lumslider.value = 100;
		pal_lumslider.onChange = function(e:UIEvent) {
			pal_lumlabel.text = "Lum: " + Std.int(pal_lumslider.value - 100);
			main_palette.lum_modifier = pal_lumslider.value / 100;
			main_palette.update();
		}
		box_lum.addComponent(pal_lumslider);
		
		pal_lumlabel = new Label();
		box_lum.addComponent(pal_lumlabel);
	}
	
	function make_range() 
	{
		range_box = new Box();
		
		range_box.x = main_tab.x + main_tab.width + 5;
		range_box.y = 5;
		range_box.width = 200;
		range_box.height = 200;
		range_box.backgroundColor = 0xCCCCCC;
	}
	function popup_monofade() {
		pal_monoedit = new VBox();
		pal_monoedit.backgroundColor = 0xEEEEEE;
		pal_monoedit.x = workbench.x + 5;
		pal_monoedit.y = workbench.y + 5;
		pal_monoedit.width = 200;
		pal_monoedit.height = 100;
		addChild(pal_monoedit);
		
		var colorbox:VBox = new VBox();
		colorbox.x = 5;
		colorbox.y = 5;
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
			pal_contextbutton.disabled = false;
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
	var workbench_mask:Sprite;
	var workbench_origin:Sprite;
	function workbench_ui() 
	{
		workbench = new Sprite();
		addChild(workbench);
		
		addChild(display_bitmap);
		
		workbench_mask = new Sprite();
		addChild(workbench_mask);
		workbench_mask.mouseEnabled = false;
		
		display_bitmap.mask = workbench_mask;
		
		workbench_origin = new Sprite();
		
		workbench_origin.mask = workbench_mask;
		
		addChild(workbench_origin);
		
		workbench_origin.x = workbench_mask.x = workbench.x;
		workbench_origin.y = workbench_mask.y = workbench.y;
		
		workbench.doubleClickEnabled = true;
		workbench.addEventListener(MouseEvent.DOUBLE_CLICK, function(e:MouseEvent) {
			
			origin = workbench_origin.globalToLocal(new Point(stage.mouseX, stage.mouseY));
		
			origin.x = Math.round(origin.x);
			origin.y = Math.round(origin.y);
			
			update_origin(origin);
		});
	}
	function update_origin(_locale:Point) 
	{
		var origin_cross_size:Float = 50 * (1 / display_bitmap.scaleX);
		
		workbench_origin.x = display_bitmap.x;
		workbench_origin.y = display_bitmap.y;
		workbench_origin.scaleX = display_bitmap.scaleX;
		workbench_origin.scaleY = display_bitmap.scaleY;
		
		workbench_origin.graphics.clear();
		workbench_origin.graphics.lineStyle(1 * (1 / display_bitmap.scaleX), 0xFF00FF);
		
		workbench_origin.graphics.moveTo(_locale.x - origin_cross_size, _locale.y);
		workbench_origin.graphics.lineTo(_locale.x + origin_cross_size, _locale.y);
		
		workbench_origin.graphics.moveTo(_locale.x, _locale.y - origin_cross_size);
		workbench_origin.graphics.lineTo(_locale.x, _locale.y + origin_cross_size);
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
		
		workbench.x = main_tab.x + main_tab.width + 10;
		workbench.y = main_tab.y + 25;
		workbench.graphics.clear();
		workbench.graphics.lineStyle(2, 0);
		workbench.graphics.beginBitmapFill(Assets.getBitmapData("embed/bg_fill.png"));
		workbench.graphics.moveTo(0, 0);
		workbench.graphics.lineTo(Lib.current.stage.stageWidth - 330, 0);
		workbench.graphics.lineTo(Lib.current.stage.stageWidth - 330, Lib.current.stage.stageHeight - 50);
		workbench.graphics.lineTo(0, Lib.current.stage.stageHeight - 50);
		workbench.graphics.lineTo(0, 0);
		
		workbench_mask.x = main_tab.x + main_tab.width + 10;
		workbench_mask.y = main_tab.y + 25;
		workbench_mask.graphics.clear();
		workbench_mask.graphics.lineStyle(2, 0);
		workbench_mask.graphics.beginBitmapFill(new BitmapData(16, 16, false, 0));
		workbench_mask.graphics.moveTo(0, 0);
		workbench_mask.graphics.lineTo(Lib.current.stage.stageWidth - 330, 0);
		workbench_mask.graphics.lineTo(Lib.current.stage.stageWidth - 330, Lib.current.stage.stageHeight - 50);
		workbench_mask.graphics.lineTo(0, Lib.current.stage.stageHeight - 50);
		workbench_mask.graphics.lineTo(0, 0);
		
		update_display_size();
		
		update_origin(origin);
	}
	
	function update_display_size() 
	{
		display_bitmap.scaleX = display_bitmap.scaleY = display_scale;
		display_bitmap.x = (workbench.x + workbench.width / 2) - (display_bitmap.width / 2);
		display_bitmap.y = (workbench.y + workbench.height / 2) - (display_bitmap.height / 2);
	}
	inline public function update_mainPalette(_pal:Int = 0) {
		box_palview.removeChild(main_palette);
		main_palette = pal[_pal];
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
		main_palette = pal[0];
		
		random_index = pal_datasource.size;
		pal_datasource.add("Random 16 x 16");
		monofade_index = pal_datasource.size;
		pal_datasource.add("Mono-fade");
	}
}
