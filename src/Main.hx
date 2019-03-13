package;

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
import sys.FileSystem;
import sys.io.FileOutput;
import sys.io.File;

import components.CheckBox;
import components.IconButton;
import components.Label;

/**
 * ...
 * @author Kaelan
 */
class Main extends Sprite 
{
	var pallet:BitmapData;
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
	var bmp_pallet:Bitmap;
	var final_sprite:Sprite = new Sprite();
	var bmp_sprite:Sprite = new Sprite();
	
	function launch() {
		pallet = Assets.getBitmapData("img/256original.png");
		
		bmp_pallet = new Bitmap(pallet);
		addChild(bmp_sprite);
		bmp_sprite.addChild(bmp_pallet);
		bmp_sprite.scaleX = bmp_sprite.scaleY = 10;
		bmp_sprite.addEventListener(MouseEvent.CLICK, set_preview);
		
		addChild(final_sprite);
		final_sprite.addChild(final_bitmap);
		final_sprite.scaleX = final_sprite.scaleY = 5;
		final_sprite.y = 160;
		final_sprite.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) {
			if (!hasEventListener(Event.ENTER_FRAME)) {
				addEventListener(Event.ENTER_FRAME, draw_preview);
			}
		});
		
		this.addEventListener(Event.ENTER_FRAME, draw_preview);
		
		make_ux();
	}
	var pal_256:CheckBox;
	var pal_doom:CheckBox;
	var pal_heretic:CheckBox;
	var pal_hexen:CheckBox;
	var pal_strife:CheckBox;
	var cur_selected:CheckBox;
	
	var info:Label;
	var texname:Label;
	
	var drawover_add:IconButton;
	var drawover_label:Label;
	var file_ref:FileReference;
	
	var export:IconButton;
	var export_label:Label;
	function make_ux() 
	{
		
		pal_256 = new CheckBox("256 Colors", true);
		addChild(pal_256);
		pal_256.onChange = function() {
			cur_selected.set(false);
			pal_256.set(true);
			cur_selected = pal_256;
			pallet = Assets.getBitmapData("img/256original.png");
			bmp_pallet.bitmapData = pallet;
		}
		pal_256.x = 170;
		pal_256.y = 10;
		cur_selected = pal_256;
		
		pal_doom = new CheckBox("Doom pallet", false);
		addChild(pal_doom);
		pal_doom.onChange = function() {
			cur_selected.set(false);
			pal_doom.set(true);
			cur_selected = pal_doom;
			pallet = Assets.getBitmapData("img/doom.png");
			bmp_pallet.bitmapData = pallet;
		}
		pal_doom.x = 170;
		pal_doom.y = 30;
		
		pal_heretic = new CheckBox("Heretic pallet", false);
		addChild(pal_heretic);
		pal_heretic.onChange = function() {
			cur_selected.set(false);
			pal_heretic.set(true);
			cur_selected = pal_heretic;
			pallet = Assets.getBitmapData("img/heretic.png");
			bmp_pallet.bitmapData = pallet;
		}
		pal_heretic.x = 170;
		pal_heretic.y = 50;
		
		pal_hexen = new CheckBox("Hexen pallet", false);
		addChild(pal_hexen);
		pal_hexen.onChange = function() {
			cur_selected.set(false);
			pal_hexen.set(true);
			cur_selected = pal_hexen;
			pallet = Assets.getBitmapData("img/hexen.png");
			bmp_pallet.bitmapData = pallet;
		}
		pal_hexen.x = 170;
		pal_hexen.y = 70;
		
		pal_strife = new CheckBox("Strife pallet", false);
		addChild(pal_strife);
		pal_strife.onChange = function() {
			cur_selected.set(false);
			pal_strife.set(true);
			cur_selected = pal_strife;
			pallet = Assets.getBitmapData("img/strife.png");
			bmp_pallet.bitmapData = pallet;
		}
		pal_strife.x = 170;
		pal_strife.y = 90;
		
		info = new Label(LabelType.DYNAMIC, "Kevs 256 pallet texture generator. Select your pallet, add a texture to draw over (Must include alpha for any results!), then click generate. This program will make 256 versions of the texture you specify.", 400, 200);
		addChild(info);
		info.x = 320;
		info.y = 10;
		
		texname = new Label(LabelType.INPUT, "My New Texture Pack");
		addChild(texname);
		texname.x = 350;
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
		drawover_add.x = 350;
		drawover_add.y = 210;
		
		drawover_label = new Label(LabelType.DYNAMIC, "Add overlay texture");
		addChild(drawover_label);
		drawover_label.x = 390;
		drawover_label.y = 210;
		
		export = new IconButton("yes");
		export.func_up = function(e:MouseEvent) {
			export_palette();
		}
		addChild(export);
		export.x = 350;
		export.y = 250;
		
		export_label = new Label(LabelType.DYNAMIC, "Generate!");
		addChild(export_label);
		export_label.x = 390;
		export_label.y = 250;
	}
	function load_drawover(e:Event):Void 
	{
		draw_over = BitmapData.fromBytes(file_ref.data);
		drawover_label.set(file_ref.name);
	}
	function set_preview(e:MouseEvent):Void 
	{
		var pos:Point = new Point(bmp_pallet.mouseX, bmp_pallet.mouseY);
		var color = pallet.getPixel(Std.int(pos.x), Std.int(pos.y));
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
		var color = pallet.getPixel(xpos, ypos);
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
		FileSystem.createDirectory("output/" + texname.value + "/");
		var intToHex:Array<String> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"];
		for (a in 0...16) {
			for (b in 0...16) {
				var color = pallet.getPixel(a, b);
				work_bitmapdata = new BitmapData(draw_over.width, draw_over.height, true, (0xFF << 24) | color);
				work_bitmapdata.draw(draw_over);
				var pathname = "output/" + texname.value + "/" + outname + intToHex[a] + intToHex[b] + ".png";
				var bytes:ByteArray = work_bitmapdata.encode(new Rectangle(0, 0, work_bitmapdata.width, work_bitmapdata.height), new PNGEncoderOptions());
				var png_out:FileOutput = File.write(pathname);
				png_out.writeBytes(bytes, 0, bytes.length);
				png_out.close();
			}
		}
		System.openFile('output\\' + texname.value + '\\');
		addEventListener(Event.ENTER_FRAME, draw_preview);
	}
}
