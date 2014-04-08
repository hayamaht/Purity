package cc.hayama.purity.services {

	import flash.net.SharedObject;

	public class SharedObjectService extends AbstructService implements IService {

		//--------------------------------------
		//   Constructor 
		//--------------------------------------

		public function SharedObjectService(name:String = null) {
			super();
			this.name = name;
		}

		//--------------------------------------
		//   Property 
		//--------------------------------------

		private var _name:String;

		private var _subject:String;

		private var so:SharedObject;

		//--------------------------------------
		// Getters / setters 
		//--------------------------------------

		public function get name():String { return _name; }

		public function set name(value:String):void {
			_name = value;

			if (name) {
				var d:int = name.indexOf(".");
				if (d > 0) {
					_name = name.substring(0, d);
					_subject = name.substring(d + 1);
				}
			}
		}

		//--------------------------------------
		//   Function 
		//--------------------------------------

		public function init():void {
			so = SharedObject.getLocal(name);
			if (_subject) {
				so.data[_subject] = {};
			}
		}

		public function save(data:Object):void {
			for (var p:String in data) {
				if (_subject) {
					so.data[_subject][p] = data[p];
				} else {
					so.data[p] = data[p];
				}
			}
			so.flush();
		}

		public function load():void {
			if (!so) {
				init();
			}

			onCompleted.dispatch("load", (_subject) ? so.data[_subject] : so.data);
		}
	}
}
