package cc.hayama.purity.parsers {
	
	import cc.hayama.purity.PurityApp;
	import cc.hayama.purity.vo.ModelConfigVO;
	import cc.hayama.utils.StringUtil;
	
	public class AppModelConfigParser extends AppConfigParser {
		
		//--------------------------------------
		//   Constructor 
		//--------------------------------------
		
		public function AppModelConfigParser() {
			super();
		}
		
		//--------------------------------------
		//   Function 
		//--------------------------------------
		
		override public function parse(data:Object):void {
			super.parse(data);
			
			var config:Vector.<ModelConfigVO> = new Vector.<ModelConfigVO>();
			_filepathes = [];
			
			for (var p:String in rawData) {
				if (validateName(p)) {
					var service:String = rawData[p].service as String;
					var vo:ModelConfigVO = new ModelConfigVO();
					var serviceStrArr:Array;
					
					vo.name = p;
					
					vo.className = (rawData[p].className)
						? data[p].className
						: PurityApp.packageName + ".models." + StringUtil.captitalizeFirstLetter(p + "Proxy");
					
					vo.voClassName = (rawData[p].vo)
						? rawData[p].vo
						: PurityApp.packageName + ".vo." + StringUtil.captitalizeFirstLetter(p + "VO");
					
					vo.preload = Boolean(rawData[p].preload);
					vo.groupData = Boolean(rawData[p].groupData);
					
					if (service) {
						serviceStrArr = service.split(":");
						vo.serviceType = serviceStrArr[0];
						if (serviceStrArr.length > 1) {
							vo.serviceParams = serviceStrArr[1];
						}
						
						if (service.indexOf("data") == 0) {
							var f:String = (serviceStrArr.length > 1)
								? serviceStrArr[1]
								: "/data/" + vo.name + ".json";
							_filepathes.push(f);
							
							if(vo.serviceParams == null) {
								vo.serviceParams = "json";
							}
							
							vo.serviceParams = f + ":" + vo.serviceParams;
						}
					}
					
					config.push(vo);
				}
			}
			
			PurityApp.modelConfig = config;
		}
	}
}
