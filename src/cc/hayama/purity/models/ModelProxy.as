package cc.hayama.purity.models {

	import com.junkbyte.console.ConsoleChannel;
	import cc.hayama.IDisposable;
	import cc.hayama.purity.services.IService;
	import cc.hayama.purity.vo.ValueObject;
	import cc.hayama.utils.ObjectUtil;
	import cc.hayama.utils.StringUtil;
	import org.osflash.signals.Signal;
	import org.puremvc.as3.patterns.proxy.Proxy;

	public class ModelProxy extends Proxy implements IDisposable {

		//--------------------------------------
		//   Constructor 
		//--------------------------------------

		public function ModelProxy(proxyName:String = null, data:Object = null) {
			super(proxyName, data);
			console = new ConsoleChannel(proxyName);
		}

		//--------------------------------------
		//   Property 
		//--------------------------------------

		public var loadWhileInit:Boolean;

		protected var console:ConsoleChannel;

		private var _onChanged:Signal = new Signal(Object);

		private var _isGroupData:Boolean;

		private var _service:IService;

		private var _voClass:Class;

		//--------------------------------------
		// Getters / setters 
		//--------------------------------------

		public function get isGroupData():Boolean {
			return _isGroupData;
		}

		public function set isGroupData(value:Boolean):void {
			_isGroupData = value;
		}

		public function get onChanged():Signal {
			return _onChanged;
		}

		public function get service():IService { return _service; }

		public function set service(value:IService):void {
			if (_service == value) {
				return;
			}
			_service = value;
			_service.onCompleted.add(onServiceCompleted);
			_service.onError.add(onServiceError);
		}

		public function get voClass():Class {
			return _voClass;
		}

		public function set voClass(value:Class):void {
			_voClass = value;
		}

		//--------------------------------------
		//   Function 
		//--------------------------------------

		override public function setData(data:Object):void {
			super.setData(data);
			onChanged.dispatch(data);
		}

		public function init():void {
			service.init();

			if (loadWhileInit) {
				load();
			}
		}

		public function send(... args):void {
			service.send.apply(service, args);
		}

		public function load():void {
			service.send("load");
		}

		public function find(params:Object):Vector.<ValueObject> {
			var vec:Vector.<ValueObject> = new Vector.<ValueObject>();

			if (!isGroupData) {
				vec.push(data);
				return vec;
			}

			if (!params) {
				return data as Vector.<ValueObject>;
			}

			for each (var vo:ValueObject in data) {
				var match:Boolean = false;
				for (var p:String in params) {
					if (vo[p] != params[p]) {
						match = false;
						break;
					} else {
						match = true;
					}
				}

				if (match) {
					vec.push(vo);
				}
			}

			return vec;
		}

		public function addValue(params:Object):void {
			if (!isGroupData) {
				for (var p:String in params) {
					if (data.hasOwnProperty(p)) {
						data[p] += params[p];
					}
				}

				setData(data);
			}
		}

		public function subValue(params:Object):void {
			if (!isGroupData) {
				for (var p:String in params) {
					if (data.hasOwnProperty(p)) {
						data[p] -= params[p];
					}
				}

				setData(data);
			}
		}

		public function setValue(params:Object):void {
			if (!isGroupData) {
				for (var p:String in params) {
					if (data.hasOwnProperty(p)) {
						data[p] = params[p];
					}
				}

				setData(data);
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

		public function dispose():void {
			service.dispose();
			data = null;
			facade.removeProxy(proxyName);
		}

		protected function parse(data:Object):Object {
			if (!voClass) {
				return null;
			}

			if (isGroupData) {
				var vec:Vector.<ValueObject> = new Vector.<ValueObject>();
				if (data is Array) {
					var len:int = data.length;
					for (var i:int = 0; i < len; ++i) {
						vec.push(new voClass(data[i]));
					}
				} else {
					for (var p:String in data) {
						var vo:ValueObject = new voClass(data[p]);
						vo.name = p;
						vec.push(vo);
					}
				}

				return vec;
			}

			return new voClass(data);
		}

		protected function onLoad(data:Object):void {
			setData(parse(data));
		}

		protected function onServiceCompleted(methodName:String, data:Object):void {
			call("on" + StringUtil.captitalizeFirstLetter(methodName), data);
		}

		protected function onServiceError(methodName:String, error:Object):void {
			call(methodName + "Error", error);
		}
	}
}
