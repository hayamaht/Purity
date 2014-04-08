package cc.hayama.purity.vo {
	
	public class RouteVO extends ValueObject {
		
		//--------------------------------------
		//   Constructor 
		//--------------------------------------
		
		public function RouteVO(params:Object = null) {
			super(params);
		}
		
		//--------------------------------------
		//   Property 
		//--------------------------------------
		
		public var value:String;
		
		public var params:Object;
		
		public var fromMediatorName:String;
		
		public var fromComponentName:String;
		
		public var mediatorName:String;
		
		public var mediatorMethodName:String;
		
		public var proxyName:String;
		
		public var proxyMethodName:String;
		
		public var gotoMediator:String;
		
		public var componentName:String;
		
		public var componentPropertyName:String;
		
		public var componentMethodName:String;
		
		public var componentPropertyValue:String;
		
		public var commandName:String;
	}
}
