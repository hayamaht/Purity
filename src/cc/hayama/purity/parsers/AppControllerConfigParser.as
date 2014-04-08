package cc.hayama.purity.parsers {

	import cc.hayama.purity.PurityApp;
	import cc.hayama.purity.vo.ControllerConfigVO;
	import cc.hayama.utils.StringUtil;

	public class AppControllerConfigParser extends AppConfigParser {

		//--------------------------------------
		//   Constructor 
		//--------------------------------------

		public function AppControllerConfigParser() {
			super();
		}

		//--------------------------------------
		//   Function 
		//--------------------------------------

		override public function parse(data:Object):void {
			super.parse(data);

			if (!rawData) {
				return;
			}

			var config:Vector.<ControllerConfigVO> = new Vector.<ControllerConfigVO>();

			var vo:ControllerConfigVO;
			var pkg:String = PurityApp.packageName + ".controllers.";

			if (rawData is Array) {

				for each (var s:String in rawData) {
					config.push(new ControllerConfigVO({
														   name: s,
														   className: pkg + StringUtil.captitalizeFirstLetter(s + "Command")
													   }));
				}

			} else {
				for (var p:String in rawData) {
					if (rawData[p] is Array) {

						for each (var c:String in rawData[p]) {
							config.push(new ControllerConfigVO({
																   name: p,
																   className: pkg + c
															   }));
						}

					} else if (rawData[p] is String) {
						config.push(new ControllerConfigVO({
															   name: p,
															   className: pkg + rawData[p]
														   }));
					}
				}
			}

			PurityApp.controllerConfig = config;
		}
	}
}
