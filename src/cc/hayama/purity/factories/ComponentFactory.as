package cc.hayama.purity.factories {

	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import cc.hayama.purity.AppFacade;
	import cc.hayama.purity.AppLocale;
	import cc.hayama.purity.ComponentType;
	import cc.hayama.purity.PurityApp;
	import cc.hayama.purity.components.ListItem;
	import cc.hayama.purity.views.Component;
	import cc.hayama.purity.vo.ViewConfigVO;
	
	import feathers.controls.Button;
	import feathers.controls.ButtonGroup;
	import feathers.controls.Check;
	import feathers.controls.Header;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.NumericStepper;
	import feathers.controls.Panel;
	import feathers.controls.ProgressBar;
	import feathers.controls.Radio;
	import feathers.controls.Scroller;
	import feathers.controls.Slider;
	import feathers.controls.TextArea;
	import feathers.controls.TextInput;
	import feathers.controls.ToggleSwitch;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.core.FeathersControl;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.ILayout;
	import feathers.layout.TiledColumnsLayout;
	import feathers.layout.TiledRowsLayout;
	import feathers.layout.VerticalLayout;
	
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.events.Event;

	public class ComponentFactory {

		//--------------------------------------
		//   Static Property 
		//--------------------------------------

		private static var componentFactories:Dictionary = new Dictionary();

		//--------------------------------------
		//   Static Function 
		//--------------------------------------

		public static function init():void {
			register(ComponentType.BUTTON, createButton);
			register(ComponentType.BUTTON_GROUP, createButtonGroup);
			register(ComponentType.CHECK, createCheck);
			register(ComponentType.HEADER, createHeader);
			register(ComponentType.IMAGE, createImage);
			register(ComponentType.LABEL, createLabel);
			register(ComponentType.LIST, createList);
			register(ComponentType.NUMERIC, createNumeric);
			register(ComponentType.PANEL, createPanel);
			register(ComponentType.PROGRESS_BAR, createProgressBar);
			register(ComponentType.TEXT_AREA, createTextArea);
			register(ComponentType.TEXT_INPUT, createTextInput);
		}

		public static function register(type:String, factory:Function):void {
			componentFactories[type] = factory;
		}

		public static function create(config:ViewConfigVO):FeathersControl {
			var c:FeathersControl = componentFactories[config.type](config);
			c.name = config.name;
			setSize(c, config.width, config.height);
			setLayoutData(c, config);

			return c;
		}

		public static function setSize(component:FeathersControl, width:Number, height:Number):void {
			if (!isNaN(width) && width > 0) {
				component.width = width;
			}

			if (!isNaN(height) && height > 0) {
				component.height = height;
			}

			component.validate();
		}

		public static function setLayoutData(component:FeathersControl, config:ViewConfigVO):void {
			if (!config.layoutData) {
				return;
			}

			if (config.layoutData == "anchor") {
				var alyd:AnchorLayoutData = new AnchorLayoutData();
				const keys:Array = [
					"left", "right", "top", "bottom",
					"verticalCenter", "horizontalCenter",
					"percentWidth", "percentHeight"
					];
				const keysLen:int = keys.length;

				var key:String;
				for (var i:int = 0; i < keysLen; ++i) {
					key = keys[i];
					if (config[key] != null) {
						alyd[key] = config[key];
					}
				}

				component.layoutData = alyd;
			}
		}

		public static function setupBackground(displayObj:*, background:Object, width:Number = NaN, height:Number = NaN):void {
			if (background == null) {
				return;
			}

			if (background is uint) {
				var w:Number = (!isNaN(width)) ? width : PurityApp.width;
				var h:Number = (!isNaN(height)) ? height : PurityApp.height;
				displayObj.backgroundSkin = new Quad(w, h, uint(background));
			}
		}

		public static function createButton(config:ViewConfigVO):Button {
			var button:Button = new Button();

			if (config.label) {
				button.label = config.label;
			}

			if (config.click) {
				button.addEventListener(Event.TRIGGERED, function(event:Event):void {
					AppFacade.instance.sendNotification(AppFacade.ROUTE, config.click);
				});
			}

			return button;
		}

		public static function createButtonGroup(config:ViewConfigVO):ButtonGroup {
			var buttonGroup:ButtonGroup = new ButtonGroup();

			for each (var obj:Object in config.buttonData) {
				obj.triggered = function(event:Event):void {
					AppFacade.instance.sendNotification(AppFacade.ROUTE, obj.click);
				};
			}

			buttonGroup.dataProvider = new ListCollection(config.buttonData);
			buttonGroup.validate();

			return buttonGroup;
		}

		public static function createCheck(config:ViewConfigVO):Check {
			var check:Check = new Check();

			if (config.label) {
				check.label = AppLocale.parse(config.label);
			}

			check.isSelected = (config.selected == true);

			if (config.change) {
				check.addEventListener(Event.CHANGE, function(event:Event):void {
					AppFacade.instance.sendNotification(AppFacade.ROUTE, config.change);
				});
			}

			return check;
		}

		public static function createHeader(config:ViewConfigVO):Header {
			var createItems:Function = function(array:Array):Vector.<DisplayObject> {
				var vec:Vector.<DisplayObject> = new Vector.<DisplayObject>();
				for each (var vo:ViewConfigVO in array) {
					vec.push(create(vo));
				}

				return vec;
			};

			var header:Header = new Header();

			if (config.title) {
				header.title = AppLocale.parse(config.title);
			}

			if (config.titleAlign) {
				header.titleAlign = config.titleAlign;
			}

			if (config.centerItems) {
				header.centerItems = createItems(config.centerItems);
			}

			if (config.rightItems) {
				header.rightItems = createItems(config.rightItems);
			}

			if (config.leftItems) {
				header.leftItems = createItems(config.leftItems);
			}

			if (config.gap) {
				header.gap = Number(config.gap);
			}

			return header;
		}

		public static function createImage(config:ViewConfigVO):ImageLoader {
			var imageLoader:ImageLoader  = new ImageLoader();

			if (config.source) {
				imageLoader.source = config.source;
			}

			if (config.complete) {
				imageLoader.addEventListener(Event.COMPLETE, function(event:Event):void {
					AppFacade.instance.sendNotification(AppFacade.ROUTE, config.complete);
				});
			}

			return imageLoader;
		}

		public static function createLabel(config:ViewConfigVO):Label {
			var label:Label = new Label();

			setSize(label, config.width, config.height);

			if (config.text) {
				config.text = AppLocale.parse(config.text);
			}

			return label;
		}

		public static function createLayoutGroup(config:ViewConfigVO):LayoutGroup {
			var layoutGroup:LayoutGroup = new LayoutGroup();

			if (config.items) {
				for each (var item:DisplayObject in config.items) {
					layoutGroup.addChild(item);
				}
			}

			return layoutGroup;
		}

		public static function createList(config:ViewConfigVO):List {
			var list:List = new List();

			if (config.layout) {
				list.layout = createLayout(config.layout);

				if (list.layout is HorizontalLayout) {
					list.horizontalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
					list.verticalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
				} else if (list.layout is VerticalLayout) {
					list.horizontalScrollPolicy = Scroller.SCROLL_POLICY_OFF;
					list.verticalScrollPolicy = Scroller.SCROLL_POLICY_AUTO;
				}
			}

			if (config.item) {
				list.itemRendererFactory = function():IListItemRenderer {
					return createListItem(config.item);
				};
			}

			list.isSelectable = (config.selectable !== false);

			if (config.selectIndex >= 0) {
				list.selectedIndex = config.selectIndex;
			}

			if (config.change) {
				list.addEventListener(Event.CHANGE, function(event:Event):void {
					AppFacade.instance.sendNotification(AppFacade.ROUTE, config.change);
				});
			}

			return list;
		}

		public static function createListItem(config:ViewConfigVO):ListItem {
			var item:ListItem = new ListItem();
			item.config = config;

			return item;
		}

		public static function createNumeric(config:ViewConfigVO):NumericStepper {
			var numeric:NumericStepper = new NumericStepper();

			numeric.maximum = (config.max) ? Number(config.max) : 100;
			numeric.minimum = (config.min) ? Number(config.min) : 0;
			numeric.value = (config.value) ? Number(config.value) : 0;
			numeric.step = (config.step) ? Number(config.step) : 1;

			if (config.change) {
				numeric.addEventListener(Event.CHANGE, function(event:Event):void {
					AppFacade.instance.sendNotification(AppFacade.ROUTE, config.change);
				});
			}

			return numeric;
		}
		
		public static function createPanel(config:ViewConfigVO):Panel {
			var panel:Panel = new Panel();
			
			if(config.header) {
				
			}
			
			if(config.footer) {
		
			}
			
			return panel;
		}

		public static function createProgressBar(config:ViewConfigVO):ProgressBar {
			var progressBar:ProgressBar = new ProgressBar();

			progressBar.minimum = (config.min) ? Number(config.min) : 0;
			progressBar.maximum = (config.max) ? Number(config.max) : 100;
			progressBar.value = (config.value) ? Number(config.value) : 0;
			progressBar.direction = (config.direction) ? config.direction : ProgressBar.DIRECTION_HORIZONTAL;

			return progressBar;
		}

		public static function createRadio(config:ViewConfigVO):Radio {
			var radio:Radio = new Radio();
			radio.label = (config.label) ? AppLocale.parse(config.label) : "";

			return radio;
		}

		public static function createSlider(config:ViewConfigVO):Slider {
			var slider:Slider = new Slider();

			slider.maximum = (config.max) ? Number(config.max) : 100;
			slider.minimum = (config.min) ? Number(config.min) : 0;
			slider.value = (config.value) ? Number(config.value) : 0;
			slider.step = (config.setp) ? Number(config.setp) : 1;
			slider.page = (config.page) ? Number(config.page) : 10;
			slider.direction = (config.direction) ? config.direction : Slider.DIRECTION_HORIZONTAL;
			slider.liveDragging = (config.liveDragging !== false);

			if (config.change) {
				slider.addEventListener(Event.CHANGE, function(event:Event):void {
					AppFacade.instance.sendNotification(AppFacade.ROUTE, config.change);
				});
			}

			return slider;
		}

		public static function createTextArea(config:ViewConfigVO):TextArea {
			var textarea:TextArea = new TextArea();

			textarea.text = (config.text) ? AppLocale.parse(config.text) : "";
			textarea.isEditable = (config.editable === true);

			if (config.maxChars) {
				textarea.maxChars = int(config.maxChars);
			}

			if (config.restrict) {
				textarea.restrict = config.restrict;
			}

			if (config.change) {
				textarea.addEventListener(Event.CHANGE, function(event:Event):void {
					AppFacade.instance.sendNotification(AppFacade.ROUTE, config.change);
				});
			}

			if (config.focusIn) {
				textarea.addEventListener(FeathersEventType.FOCUS_IN, function(event:Event):void {
					AppFacade.instance.sendNotification(AppFacade.ROUTE, config.focusIn);
				});
			}

			if (config.focusOut) {
				textarea.addEventListener(FeathersEventType.FOCUS_OUT, function(event:Event):void {
					AppFacade.instance.sendNotification(AppFacade.ROUTE, config.focusOut);
				});
			}

			return textarea;
		}

		public static function createTextInput(config:ViewConfigVO):TextInput {
			var textinput:TextInput = new TextInput();

			textinput.text = (config.text) ? AppLocale.parse(config.text) : "";
			textinput.prompt = (config.prompt) ? AppLocale.parse(config.prompt) : "";
			textinput.displayAsPassword = (config.password === true);
			textinput.isEditable = (config.editable === true);

			if (config.maxChars) {
				textinput.maxChars = int(config.maxChars);
			}

			if (config.restrict) {
				textinput.restrict = config.restrict;
			}

			if (config.change) {
				textinput.addEventListener(Event.CHANGE, function(event:Event):void {
					AppFacade.instance.sendNotification(AppFacade.ROUTE, config.change);
				});
			}

			if (config.focusIn) {
				textinput.addEventListener(FeathersEventType.FOCUS_IN, function(event:Event):void {
					AppFacade.instance.sendNotification(AppFacade.ROUTE, config.focusIn);
				});
			}

			if (config.focusOut) {
				textinput.addEventListener(FeathersEventType.FOCUS_OUT, function(event:Event):void {
					AppFacade.instance.sendNotification(AppFacade.ROUTE, config.focusOut);
				});
			}

			if (config.enter) {
				textinput.addEventListener(FeathersEventType.ENTER, function(event:Event):void {
					AppFacade.instance.sendNotification(AppFacade.ROUTE, config.enter);
				});
			}

			return textinput;
		}

		public static function createToggle(config:ViewConfigVO):ToggleSwitch {
			var toggle:ToggleSwitch = new ToggleSwitch();

			toggle.isSelected = (config.selected === true);
			toggle.showLabels = (config.showLabels !== false);
			toggle.showThumb = (config.showThumb !== false);

			if (config.onText) {
				toggle.onText = AppLocale.parse(config.onText);
			}

			if (config.offText) {
				toggle.offText = AppLocale.parse(config.offText);
			}

			if (config.change) {
				toggle.addEventListener(Event.CHANGE, function(event:Event):void {
					AppFacade.instance.sendNotification(AppFacade.ROUTE, config.change);
				});
			}

			return toggle;
		}

		public static function createLayout(config:Object):ILayout {
			const factory:Function = function(type:String):ILayout {
				return (type == "anchor") ? new AnchorLayout() :
					(type == "horizontal") ? new HorizontalLayout() :
					(type == "vertical") ? new VerticalLayout() :
					(type == "tiledCol") ? new TiledColumnsLayout() :
					(type == "tiledRow") ? new TiledRowsLayout() : null;
			};

			if (config is String) {
				return factory(String(config));
			}

			var ly:ILayout = factory(config.type);

			for (var p:String in config) {
				if (p in ly) {
					ly[p] = config[p];
				}
			}

			return ly;
		}
	}
}
