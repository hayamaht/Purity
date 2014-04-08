package cc.hayama.purity.parsers {

	import cc.hayama.purity.AppLocale;
	import cc.hayama.purity.PurityApp;

	public class AppSettingDataParser extends AppConfigParser {

		//--------------------------------------
		//   Constructor 
		//--------------------------------------

		public function AppSettingDataParser() {
			super();
		}

		//--------------------------------------
		//   Function 
		//--------------------------------------

		override public function parse(data:Object):void {
			super.parse(data);

			PurityApp.packageName = rawData.packageName;

			_filepathes = [];

			parseLocale(rawData.locale);
			parseResource(rawData.resource);
		}

		private function parseLocale(data:Object):void {
			if (!data) {
				return;
			}

			var locales:Array = [];
			var defaultLocale:String = AppLocale.currentLocale;
			var len:int = data.length;

			for (var i:int = 0; i < len; ++i) {
				var locale:String = data[i];
				if (locale.charAt(0) == "*") {
					locale = locale.substring(1);

					if (defaultLocale == "") {
						defaultLocale = locale;
					}
				}

				locales[i] = locale;

				_filepathes.push("/locale/" + locale + ".json");
			}

			AppLocale.locales = locales;
			AppLocale.currentLocale = defaultLocale;
		}

		private function parseResource(data:Object):void {
			for each (var s:String in data) {
				_filepathes.push(s);
			}
		}
	}
}
