package cc.hayama.purity {

	import cc.hayama.purity.managers.LoadManager;
	import cc.hayama.purity.parsers.AppConfigParser;

	public class AppConfigLoadItem {

		//--------------------------------------
		//   Constructor 
		//--------------------------------------

		public function AppConfigLoadItem(path:String,
										  parser:AppConfigParser,
										  onCompletedFunc:Function = null) {

			this.parser = parser;
			this.name = LoadManager.getNameByPath(path);
			this.completedCallback = completedCallback;
			LoadManager.instance.addItem(path, null, onCompleted);
		}

		//--------------------------------------
		//   Property 
		//--------------------------------------

		protected var parser:AppConfigParser;

		protected var name:String;

		protected var completedCallback:Function;

		//--------------------------------------
		//   Function 
		//--------------------------------------

		protected function onCompleted():void {
			parser.parse(LoadManager.getContent(name));

			if (parser.filepathes && parser.filepathes.length > 0) {
				LoadManager.instance.addItems(parser.filepathes);
			}

			if (completedCallback != null) {
				completedCallback();
			}
		}
	}


}
