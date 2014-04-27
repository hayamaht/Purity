package cc.hayama.purity.vo {

	public dynamic class ViewConfigVO extends ValueObject {

		//--------------------------------------
		//   Constructor 
		//--------------------------------------

		public function ViewConfigVO(params:Object = null) {
			super(params);
		}

		//--------------------------------------
		//   Property 
		//--------------------------------------

		public var type:String;

		public var className:String;
		
		public var container:String;
		
		public var containerClassName:String;
		
		public var parent:String;

		public var children:Vector.<ViewConfigVO>;

		public var background:Object;

		public var isDefault:Boolean;

		public var index:int;

		public var shows:Vector.<String>;

		public var hides:Vector.<String>;

		public var drawerDir:String;

		public var width:Number;

		public var height:Number;

		public var signals:Object;

		public var events:Object;

		public var layout:String;
		
		public var layoutData:String;
		
		public var dataSource:String;
	}
}
