package cc.hayama.purity.factories {

	import flash.utils.Dictionary;
	
	import cc.hayama.purity.AppFacade;
	import cc.hayama.purity.AppLocale;
	import cc.hayama.purity.ComponentType;
	import cc.hayama.purity.PurityApp;
	import cc.hayama.purity.vo.ComponentConfigVO;
	
	import feathers.controls.Button;
	import feathers.controls.ButtonGroup;
	import feathers.controls.Check;
	import feathers.controls.Header;
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.NumericStepper;
	import feathers.controls.ProgressBar;
	import feathers.controls.Radio;
	import feathers.controls.Slider;
	import feathers.controls.TextArea;
	import feathers.controls.TextInput;
	import feathers.controls.ToggleSwitch;
	import feathers.core.FeathersControl;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	
	import starling.display.DisplayObject;
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
			register(ComponentType.PROGRESS_BAR, createProgressBar);
			register(ComponentType.TEXT_AREA, createTextArea);
			register(ComponentType.TEXT_INPUT, createTextInput);
		}

		public static function register(type:String, factory:Function):void {
			componentFactories[type] = factory;
		}

		public static function create(config:ComponentConfigVO):FeathersControl {
			return componentFactories[config.type](config);
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

		public static function setPosition(component:FeathersControl, x:*, y:*):void {
			if (!x && !y) {
				return;
			}

			var parser:Function = function(value:*):Number {
				if (value is String) {
					var v:Number = 0;
					var matches:Array = String(value).match(/(\d+[+-])?{(center|middle|top|bottom|left|right)}([+-]\d+)?/);
					if (matches && matches.length > 1) {
						var d:Number = 0;
						var ds:String = "";
						var op:String = "";
						var w:Number = PurityApp.width;
						var h:Number = PurityApp.height;

						v = (matches[2] == "top") ? 0 :
							(matches[2] == "bottom") ? h - component.height :
							(matches[2] == "left") ? 0 :
							(matches[2] == "right") ? w - component.width :
							(matches[2] == "center") ? (w - component.width) * 0.5 :
							(matches[2] == "middle") ? (h - component.height) * 0.5 : 0;

						if (matches[1] && matches[1].length > 0) {
							ds = matches[1];
							d = Number(ds.substring(0, ds.length - 1));
							op = ds.substr(-1);
							if (op == "-") {
								v = d - v;
							} else {
								v = d + v;
							}
						} else if (matches[3] && matches[3].length > 0) {
							ds = matches[3];
							d = Number(ds.substring(1));
							op = ds.substr(0, 1);
							if (op == "-") {
								v -= d;
							} else {
								v += d;
							}
						}

						return v;
					}

					return value;
				}
			};

			component.x = parser(x);
			component.y = parser(y);
		}

		public static function createButton(config:ComponentConfigVO):Button {
			var button:Button = new Button();
			button.name = config.name;

			setSize(button, config.width, config.height);

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

		public static function createButtonGroup(config:ComponentConfigVO):ButtonGroup {
			var buttonGroup:ButtonGroup = new ButtonGroup();
			buttonGroup.name = config.name;

			setSize(buttonGroup, config.width, config.height);

			for each (var obj:Object in config.buttonData) {
				obj.triggered = function(event:Event):void {
					AppFacade.instance.sendNotification(AppFacade.ROUTE, obj.click);
				};
			}

			buttonGroup.dataProvider = new ListCollection(config.buttonData);
			buttonGroup.validate();

			return buttonGroup;
		}

		public static function createCheck(config:ComponentConfigVO):Check {
			var check:Check = new Check();
			check.name = config.name;

			setSize(check, config.width, config.height);

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

		public static function createHeader(config:ComponentConfigVO):Header {
			var createItems:Function = function(array:Array):Vector.<DisplayObject> {
				var vec:Vector.<DisplayObject> = new Vector.<DisplayObject>();
				for each (var vo:ComponentConfigVO in array) {
					vec.push(create(vo));
				}

				return vec;
			};

			var header:Header = new Header();

			setSize(header, config.width, config.height);

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

		public static function createImage(config:ComponentConfigVO):ImageLoader {
			var imageLoader:ImageLoader  = new ImageLoader();
			imageLoader.name = config.name;

			setSize(imageLoader, config.width, config.height);

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

		public static function createLabel(config:ComponentConfigVO):Label {
			var label:Label = new Label();
			label.name = config.name;

			setSize(label, config.width, config.height);

			if (config.text) {
				config.text = AppLocale.parse(config.text);
			}

			return label;
		}

		public static function createLayoutGroup(config:ComponentConfigVO):LayoutGroup {
			var layoutGroup:LayoutGroup = new LayoutGroup();
			layoutGroup.name = config.name;

			if (config.layout) {
				layoutGroup.layout = LayoutFactory.create(config.layout);
			}

			if (config.items) {
				for each (var item:DisplayObject in config.items) {
					layoutGroup.addChild(item);
				}
			}

			return layoutGroup;
		}

		public static function createList(config:ComponentConfigVO):List {
			var list:List = new List();
			list.name = config.name;

			setSize(list, config.width, config.height);

			if (config.item) {

			}

			if (config.change) {
				list.addEventListener(Event.CHANGE, function(event:Event):void {
					AppFacade.instance.sendNotification(AppFacade.ROUTE, config.change);
				});
			}

			return list;
		}

		public static function createNumeric(config:ComponentConfigVO):NumericStepper {
			var numeric:NumericStepper = new NumericStepper();
			numeric.name = config.name;

			setSize(numeric, config.width, config.height);

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

		public static function createProgressBar(config:ComponentConfigVO):ProgressBar {
			var progressBar:ProgressBar = new ProgressBar();

			progressBar.minimum = (config.min) ? Number(config.min) : 0;
			progressBar.maximum = (config.max) ? Number(config.max) : 100;
			progressBar.value = (config.value) ? Number(config.value) : 0;
			progressBar.direction = (config.direction) ? config.direction : ProgressBar.DIRECTION_HORIZONTAL;

			return progressBar;
		}

		public static function createRadio(config:ComponentConfigVO):Radio {
			var radio:Radio = new Radio();
			radio.name = config.name;

			setSize(radio, config.width, config.height);

			radio.label = (config.label) ? AppLocale.parse(config.label) : "";

			return radio;
		}

		public static function createSlider(config:ComponentConfigVO):Slider {
			var slider:Slider = new Slider();
			slider.name = config.name;

			setSize(slider, config.width, config.height);

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

		public static function createTextArea(config:ComponentConfigVO):TextArea {
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

		public static function createTextInput(config:ComponentConfigVO):TextInput {
			var textinput:TextInput = new TextInput();
			textinput.name = config.name;

			setSize(textinput, config.width, config.height);

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

		public static function createToggle(config:ComponentConfigVO):ToggleSwitch {
			var toggle:ToggleSwitch = new ToggleSwitch();
			toggle.name = config.name;

			setSize(toggle, config.width, config.height);

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
	}
}
