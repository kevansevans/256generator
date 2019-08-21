package;

import haxe.ui.components.Button;
import sys.FileSystem;
import sys.io.File;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
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
	static var pal_datasource:ArrayDataSource<Label>;
	static var main_palette:WorkBitmap;
	
	var loaded_bitmap:Bitmap;
	var loaded_hex:Array<Array<PixelColor>>;
	var work_bitmapdata:BitmapData;
	var display_bitmap:Bitmap;
	
	var current_palette:Int = 0;
	var hue_negative:Bool = false;
	
	static var random_index:Int = -1;
	static var monofade_index:Int = -1;
	
	public function new() 
	{
		super();
		
		//Backend Initialize
		getPalAndColorLists(); //get palettes and index their colors
		
		//Frontend Initialize
		init_ui();
		init_events();
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent) {
			if (e.keyCode == Keyboard.SPACE) update_workBitmap();
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
		
		bitmap_display();
		
		resize_ui();
	}
	
	var pal_dropdown:DropDown;
	var pal_contextbutton:Button;
	function palette_tab() {
		palette_box = new ScrollView();
		palette_box.text = "Palette";
		main_tab.addComponent(palette_box);
		
		pal_dropdown = new DropDown();
		pal_dropdown.dataSource = pal_datasource;
		palette_box.addComponent(pal_dropdown);
		pal_dropdown.selectedIndex = 0;
		pal_dropdown.text = "Palette";
		pal_dropdown.width = 150;
		pal_dropdown.dropdownHeight = 200;
		pal_dropdown.onChange = function(e:UIEvent) {
			if (pal_dropdown.selectedIndex == random_index) {
				palette_box.removeChild(main_palette);
				var temp_bitmap:WorkBitmap = new WorkBitmap(random_palette(), 16, 16);
				main_palette = temp_bitmap;
				palette_box.addChild(main_palette);
			} else if (pal_dropdown.selectedIndex == monofade_index) {
				//monofade bitmap here
			} else {
				//update_mainPalette(pal_dropdown.selectedIndex);
			}
			resize_ui();
		}
		
		pal_contextbutton = new Button();
		palette_box.addComponent(pal_contextbutton);
		pal_contextbutton.text = "Context";
		pal_contextbutton.y = 0;
		pal_contextbutton.x = 160;
		
		//palette_box.addChild(main_palette);
		main_palette.x = 7;
		main_palette.y = 40;
		main_palette.width = main_palette.height = 275;
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
	
	function bitmap_display() 
	{
		
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
		
		main_palette.x = 7;
		main_palette.y = 40;
		main_palette.width = main_palette.height = 275;
	}
	inline public function update_mainPalette(_pal:Int = 0) {
		palette_box.removeChild(main_palette);
		if (!hue_negative) main_palette = pal[_pal];
		else if (hue_negative) main_palette = pal_neg[_pal];
		palette_box.addChild(main_palette);
	}
	function update_workBitmap() {
		
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
			var p_bitmap = new BitmapData(16, 16, false, 0xFFFFFFFF);
			p_bitmap.draw(t_bitmap);
			
			Main.pal[p_id] = new WorkBitmap(p_bitmap, 16, 16);
			
			//create label for dropdown
			var pal_label:Label = new Label();
			var l_text = StringTools.replace(a, ".png", "");
			l_text = StringTools.replace(l_text, ".jpg", "");
			l_text = StringTools.replace(l_text, "_", " ");
			pal_label.text = l_text;
			pal_datasource.add(pal_label);
			
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
			}
			Main.pal_neg[p_id].retroApply();
			
			++p_id;
		}
		main_palette = pal[0];
		
		random_index = pal_datasource.size;
		var random:Label = new Label();
		random.text = "Random 16 x 16";
		pal_datasource.add(random);
		monofade_index = pal_datasource.size;
		var mono:Label = new Label();
		mono.text = "Mono-fade";
		pal_datasource.add(mono);
	}
}
