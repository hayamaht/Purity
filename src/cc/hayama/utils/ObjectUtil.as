package cc.hayama.utils {

	public class ObjectUtil {

		//--------------------------------------
		//   Static Function 
		//--------------------------------------

		public static function toArray(target:Object):Array {
			if(target is Array) {
				return target as Array;
			}
			
			var a:Array = [];
			
			if (target is String || target is Number || target is Boolean || target is int) {
				a.push(target);
			}else {
				for (var p:String in target) {
					a.push(target[p]);
				}
			}
			
			return a;
		}
	}
}
