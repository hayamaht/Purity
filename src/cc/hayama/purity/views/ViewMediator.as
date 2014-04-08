package cc.hayama.purity.views {

	import com.junkbyte.console.ConsoleChannel;
	
	import flash.utils.Dictionary;
	
	import cc.hayama.IDisposable;
	import cc.hayama.purity.PurityApp;
	import cc.hayama.purity.ViewType;
	import cc.hayama.utils.ObjectUtil;
	
	import feathers.core.FeathersControl;
	
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import starling.display.Sprite;

	public class ViewMediator extends Mediator implements IDisposable {

		//--------------------------------------
		//   Constructor 
		//--------------------------------------

		public function ViewMediator(mediatorName:String = null, viewComponent:Object = null) {
			super(mediatorName, viewComponent);
			console = new ConsoleChannel(mediatorName);
		}

		//--------------------------------------
		//   Property 
		//--------------------------------------

		public var drawerDir:String = null;

		protected var components:Dictionary = new Dictionary();

		protected var console:ConsoleChannel;

		private var _data:Object;

		private var _type:String;

		private var _index:int;

		private var _isDefault:Boolean;

		private var _asControl:FeathersControl;

		//--------------------------------------
		// Getters / setters 
		//--------------------------------------

		public function get asControl():FeathersControl {
			return _asControl;
		}

		public function set asControl(value:FeathersControl):void {
			if (asControl == value || value == null) {
				return;
			}

			_asControl = value;
			container.addChild(asControl);
		}

		public function get container():Sprite { return viewComponent as Sprite; }

		public function get data():Object {
			return _data;
		}

		public function set data(value:Object):void {
			_data = value;
		}

		public function get index():int {
			return _index;
		}

		public function set index(value:int):void {
			_index = value;
		}

		public function get isDefault():Boolean {
			return _isDefault;
		}

		public function set isDefault(value:Boolean):void {
			_isDefault = value;
		}

		public function get type():String {
			return _type;
		}

		public function set type(value:String):void {
			_type = value;
		}

		//--------------------------------------
		//   Function 
		//--------------------------------------

		public function show():void {
			console.info("show()");
			sendNotification(getMediatorName() + ".show");

			if (type == ViewType.NAV) {
				PurityApp.nav.showScreen(mediatorName);
			} else if (type == ViewType.DRAWER) {
				if (drawerDir == "top") {
					PurityApp.drawers.toggleTopDrawer();
				} else if (drawerDir == "bottom") {
					PurityApp.drawers.toggleBottomDrawer();
				} else if (drawerDir == "left") {
					PurityApp.drawers.toggleLeftDrawer();
				} else if (drawerDir == "right") {
					PurityApp.drawers.toggleRightDrawer();
				}
			}
		}

		public function hide():void {
			console.info("hide()");
			sendNotification(getMediatorName() + ".hide");

			if (type == ViewType.NAV) {
				PurityApp.nav.clearScreen();
			} else if (type == ViewType.DRAWER) {
				if (drawerDir == "top") {
					PurityApp.drawers.toggleTopDrawer();
				} else if (drawerDir == "bottom") {
					PurityApp.drawers.toggleBottomDrawer();
				} else if (drawerDir == "left") {
					PurityApp.drawers.toggleLeftDrawer();
				} else if (drawerDir == "right") {
					PurityApp.drawers.toggleRightDrawer();
				}
			}
		}

		public function getComponent(name:String):Component {
			return components[name] as Component;
		}

		public function setComponent(name:String, component:Component):void {
			if (components[name]) {
				throw new Error("The given name is existing.");
				return;
			}

			components[name] = component;
			if(asControl) {
				asControl.addChild(component.control);
			}else {
				container.addChild(component.control);
			}
		}

		public function call(method:String, ... args):void {
			try {
				var f:Function = this[method] as Function;
			} catch (err:Error) {
				return;
			}

			if (f.length == 0) {
				f.apply(this);
			} else {
				var a:Array = (f.length > 1 && args.length == 1)
					? ObjectUtil.toArray(args[0])
					: args;
				f.apply(this, a);
			}
		}

		public function resize(width:Number, heigh:Number):void {
			//Override in subclasses
		}

		public function init():void {
			//Override in subclasses
		}

		public function dispose():void {
			components = null;
			facade.removeMediator(mediatorName);
		}
	}
}
