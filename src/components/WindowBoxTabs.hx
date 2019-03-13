package components;

import openfl.Assets;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.Lib;
import openfl.events.Event;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.text.TextFieldAutoSize;

import components.WindowBox;

/**
 * ...
 * @author kevansevans
 */
class WindowBoxTabs extends Sprite
{
	private var fontA:TextFormat = new TextFormat(Assets.getFont("fonts/Verdana Bold.ttf").fontName, 14, 0xFFFFFF, null, null, null, null, null, TextFormatAlign.LEFT);
	private var fontB:TextFormat = new TextFormat(null, 16, 0, null, null, null, null, null, TextFormatAlign.LEFT);
	public var drag(default, set):Bool = false;
	private var windowBar:Sprite;
	private var barLabel:TextField;
	public var title(default, set):String;
	public var positive:IconButton;
	public var negative:IconButton;
	private var wWidth:Int;
	private var wHeight:Int;
	private var fill:Int = 0xEEEEEE;
	public var tabs:IconBar;
	public var key_map:Map<IconButton, Null<WindowBox>>;
	public var current_tab:WindowBox;
	public function new(_title:String, _type:Int, _width:Int=255, _height:Int=255) 
	{
		super();
		
		this.wWidth = _width;
		this.wHeight = _height;
		
		this.windowBar = Assets.getMovieClip("assets:WindowBar");
		this.addChild(this.windowBar);
		this.windowBar.width = _width;
		
		this.barLabel = new TextField();
		this.barLabel.setTextFormat(this.fontA);
		this.addChild(this.barLabel);
		this.barLabel.x = 2;
		this.barLabel.y = -1;
		this.barLabel.width = this.windowBar.width - 30;
		this.barLabel.text = _title;
		this.barLabel.selectable = false;
		this.barLabel.mouseEnabled = false;
		
		this.negative = new IconButton("no");
		this.addChild(this.negative);
		this.negative.x = this.wWidth - 32;
		
		this.tabs = new IconBar();
		this.key_map = new Map();
		
		this.addChild(tabs);
		tabs.x = 5;
		tabs.y = windowBar.height + 5;
		
		this.addEventListener(Event.ADDED_TO_STAGE, _update);
	}
	
	function _update(e:Event):Void 
	{
		render();
	}
	public function add_tab(_icon:IconButton, ?_window:WindowBox) {
		tabs.add_icon(_icon);
		key_map[_icon] = _window;
		
		if (_window != null) {
			this.addChild(key_map[_icon]);
			key_map[_icon].visible = false;
		}
		
		if (current_tab == null) current_tab = _window;
		
		render();
	}
	public function switch_tab(_icon:IconButton) {
		for (a in key_map) {
			if (a == null) continue;
			a.visible = false;
		}
		current_tab = key_map[_icon];
		key_map[_icon].visible = true;
		render();
	}
	public function render() {
		
		if (current_tab != null) {
			wWidth = current_tab.width > tabs.width + 30 ? Std.int(current_tab.width) : Std.int(tabs.width);
			wHeight = Std.int(current_tab.x + current_tab.wHeight);
		}
		this.windowBar.width = this.wWidth;
		
		tabs.x = 5;
		tabs.y = windowBar.height + 5;
		
		for (a in key_map) {
			if (a == null) continue;
			a.x = 0;
			a.y = windowBar.height + tabs.height - 15;
		}
		
		this.graphics.clear();
		this.graphics.lineStyle(1, 0xDDDDDD);
		this.graphics.beginFill(this.fill, 1);
		this.graphics.moveTo(0, 20);
		this.graphics.lineTo(0, this.wHeight + 20);
		this.graphics.lineTo(this.wWidth, this.wHeight + 20);
		this.graphics.lineTo(this.wWidth, 20);
		this.graphics.lineTo(0, 20);
		
		this.negative.x = this.wWidth - 32;
		this.negative.y = 2;
	}
	function stop_drag(e:MouseEvent):Void 
	{
		this.stopDrag();
		if (this.x + this.wWidth < 0) {
			this.x = (this.wWidth * -1) + 50;
		} else if (this.x > Lib.current.stage.stageWidth) {
			this.x = Lib.current.stage.stageWidth - 50;
		}
		if (this.y < 35) {
			this.y = 35;
		} else if (this.y > Lib.current.stage.stageHeight) {
			this.y = Lib.current.stage.stageHeight - 95;
		}
	}
	function drag_window(e:MouseEvent):Void 
	{
		this.startDrag();
	}
	function set_drag(_bool) {
		if (_bool) {
			this.windowBar.addEventListener(MouseEvent.MOUSE_DOWN, this.drag_window);
			this.windowBar.addEventListener(MouseEvent.MOUSE_UP, this.stop_drag);
			Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, this.stop_drag);
		} else {
			this.windowBar.removeEventListener(MouseEvent.MOUSE_DOWN, this.drag_window);
			this.windowBar.removeEventListener(MouseEvent.MOUSE_UP, this.stop_drag);
			Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, this.stop_drag);
		}
		return this.drag = _bool;
	}
	function set_title(_v:String):String {
		this.barLabel.text = _v;
		return title = _v;
	}
}
