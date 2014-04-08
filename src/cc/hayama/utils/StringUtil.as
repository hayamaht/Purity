package cc.hayama.utils {

	public class StringUtil {

		//--------------------------------------
		//   Static Function 
		//--------------------------------------

		public static function captitalizeFirstLetter(str:String):String {
			return str.replace(/^(\w)/g, function($0):* {return $0.toUpperCase();});
		}
	}
}
