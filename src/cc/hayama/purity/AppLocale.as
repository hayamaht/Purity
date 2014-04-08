package cc.hayama.purity {

	import com.junkbyte.console.Cc;
	import flash.utils.Dictionary;
	import mx.utils.StringUtil;

	public class AppLocale {

		//--------------------------------------
		//   Static Property 
		//--------------------------------------

		private static var _currentLocale:String = "";

		private static var _locales:Array = [];

		private static var localeData:Dictionary = new Dictionary;

		//--------------------------------------
		//   Static getters / setters 
		//--------------------------------------

		public static function get locales():Array { return _locales; }

		public static function set locales(value:Array):void { _locales = value; }

		public static function get currentLocale():String { return _currentLocale; }

		public static function set currentLocale(value:String):void {
			if (_currentLocale == value) {
				return;
			}

			_currentLocale = value;
		}

		//--------------------------------------
		//   Static Function 
		//--------------------------------------

		public static function getValue(name:String):Object {
			var a:Array = name.split(".");

			if (a.length == 1) {
				return localeData[currentLocale][a[0]];
			}

			if (a.length > 1) {
				return localeData[currentLocale][a[0]][a[1]];
			}

			return null;
		}

		public static function getString(name:String, ... args):String {
			var a:Array = (args[0] is Array) ? args[0] : args;
			return StringUtil.substitute(getValue(name) as String, a);
		}

		public static function parse(value:String):String {
			var a:Array = value.match(/{{([^}}]*)}}/);
			if (a && a.length > 1) {
				return getString(a[1]);
			}

			return value;
		}

		public static function addLocaleData(locale:String, data:Object):void {
			if (_currentLocale == null) {
				_currentLocale = locale;
			}

			Cc.info("AppLocale.addLocalData(): locale=" + locale);

			localeData[locale] = data;
		}
	}
}
