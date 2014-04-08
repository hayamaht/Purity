package cc.hayama.purity.parsers {

	public class AppConfigParser {

		//--------------------------------------
		//   Constructor 
		//--------------------------------------

		public function AppConfigParser() {
		}

		//--------------------------------------
		//   Property 
		//--------------------------------------

		protected var _filepathes:Array;

		private var _rowData:Object;

		//--------------------------------------
		// Getters / setters 
		//--------------------------------------

		public function get filepathes():Array { return _filepathes; }

		public function get rawData():Object { return _rowData; }

		//--------------------------------------
		//   Function 
		//--------------------------------------

		public function parse(data:Object):void {
			_rowData = JSON.parse(data as String);
		}

		public function validateName(name:String):Boolean {
			return name.search(/^_\w+_$/) < 0 && name.charAt(0) != "~";
		}
	}
}
