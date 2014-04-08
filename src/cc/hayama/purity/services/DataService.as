package cc.hayama.purity.services {

	import com.greensock.events.LoaderEvent;
	import cc.hayama.purity.managers.LoadManager;

	public class DataService extends AbstructService implements IService {

		//--------------------------------------
		//   Constructor 
		//--------------------------------------

		public function DataService(filename:String = null) {
			super();
			this.filename = filename;
		}

		//--------------------------------------
		//   Property 
		//--------------------------------------

		private var _filename:String;

		private var _type:String;

		private var rawData:Object;

		//--------------------------------------
		// Getters / setters 
		//--------------------------------------

		public function get filename():String { return _filename; }

		public function set filename(value:String):void {
			var a:Array = value.split(":");
			_filename = a[0];
			if (a.length == 2) {
				_type = a[1];
			}
		}

		public function get type():String { return _type; }

		//--------------------------------------
		//   Function 
		//--------------------------------------

		public function init():void {
			var str:String = LoadManager.getContent(LoadManager.getNameByPath(filename));
			rawData = (type == "json") ? JSON.parse(str) :
				(type == "xml") ? new XML(str) :
				str;
		}

		public function load():void {
			if (!rawData) {
				LoadManager.load(filename, { onComplete: onCompleted });
			} else {
				onCompleted();
			}
		}

		private function onCompleted(event:LoaderEvent = null):void {
			if (!rawData) {
				init();
			}

			onCompleted.dispatch("load", rawData);
		}
	}
}
