package cc.hayama.purity.managers {

	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.DataLoader;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.MP3Loader;
	import com.greensock.loading.SWFLoader;
	import com.greensock.loading.VideoLoader;
	import com.greensock.loading.core.LoaderCore;
	import flash.display.Sprite;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import org.osflash.signals.Signal;

	public class LoadManager {

		//--------------------------------------
		//   Static Property 
		//--------------------------------------

		private static var _instance:LoadManager = new LoadManager();

		//--------------------------------------
		//   Static getters / setters 
		//--------------------------------------

		public static function get instance():LoadManager { return _instance; }

		//--------------------------------------
		//   Static Function 
		//--------------------------------------

		public static function getContent(name:String):* {
			return LoaderMax.getContent(name);
		}

		public static function getLoader(name:String):LoaderCore {
			return LoaderMax.getLoader(name);
		}

		public static function getClass(name:String, className:String):Class {
			var loader:SWFLoader = LoaderMax.getLoader(name) as SWFLoader;
			if (loader) {
				return loader.getClass(className);
			}

			return null;
		}

		public static function getInstance(name:String, className:String):Sprite {
			var c:Class = getClass(name, className);
			if (c) {
				return new c;
			}

			return null;
		}

		public static function getNameByPath(path:String):String {
			var p:String = getPath(path);
			return p.split(".")[0];
		}

		public static function load(path:String, vars:Object = null):LoaderCore {
			var loader:LoaderCore = create(path, vars);
			loader.load();
			return loader;
		}

		public static function create(path:String, vars:Object = null):LoaderCore {
			var p:String = getPath(path);
			var a:Array = p.split(".");
			var name:String = (vars && vars.name) ? vars.name : a[0];
			var ext:String = (a.length == 2) ? a[1] : vars.type;

			if (!ext) {
				throw new Error("The item you try to load has no type.");
				return null;
			}

			vars ||= {};
			vars.name = name;

			switch (ext) {
				case "swf":  {
					return new SWFLoader(p, vars);
				}

				case "png":
				case "gif":
				case "jpg":
				case "jpeg":  {
					return new ImageLoader(p, vars);
				}

				case "mp3":  {
					return new MP3Loader(p, vars);
				}

				case "f4v":
				case "mp4":
				case "flv":  {
					return new VideoLoader(p, vars);
				}

				default:  {
					return new DataLoader(p, vars);
				}
			}
		}

		public static function getPath(path:String):String {
			var a:Array = path.split("/");

			if (a[0] == "") {
				a.shift();
				return a.join("/");
			}

			return "assets/" + path;
		}

		public static function hasItem(name:String):Boolean {
			return LoaderMax.getLoader(name) != null;
		}

		//--------------------------------------
		//   Constructor 
		//--------------------------------------

		public function LoadManager() {
			if (_instance) {
				throw new Error("This class is a Singleton.");
			}
		}

		//--------------------------------------
		//   Property 
		//--------------------------------------

		private var _onCompleted:Signal = new Signal();

		private var _onProgress:Signal = new Signal(Number);

		private var _onError:Signal = new Signal(LoaderCore, String);

		private var queue:LoaderMax = new LoaderMax({
														onComplete: onQueueCompleted,
														onProgress: onQueueProgress,
														onError: onQueueError
													});

		//--------------------------------------
		// Getters / setters 
		//--------------------------------------

		public function get onCompleted():Signal { return _onCompleted; }

		public function get onError():Signal { return _onError; }

		public function get onProgress():Signal { return _onProgress; }

		//--------------------------------------
		//   Function 
		//--------------------------------------

		public function addItem(path:String, vars:Object = null, pauseFunc:Function = null):void {
			if (pauseFunc != null) {
				vars ||= {};
				vars.onComplete = function(e:LoaderEvent):void {
					pause();
					pauseFunc();
					resume();
				};
			}

			queue.append(create(path, vars));
		}

		public function addItems(pathes:Array, vars:Array = null, pauseFunc:Function = null):void {
			var v:Object = null;

			if (pauseFunc != null) {
				v = { onComplete: function(event:LoaderEvent):void {
					pause();
					pauseFunc();
					resume();
				} };
			}

			var loader:LoaderMax = new LoaderMax(v);
			var len:int = pathes.length;
			var vv:Object;
			var p:String;

			for (var i:int = 0; i < len; ++i) {
				vv = (vars) ? vars[i] : null;
				p = pathes[i];
				
				loader.append(create(p, vv));
			}

			queue.append(loader);
		}

		public function start():void {
			LoaderMax.defaultContext = new LoaderContext(false, ApplicationDomain.currentDomain, SecurityDomain.currentDomain);
			queue.load();
		}

		public function pause():void {
			queue.pause();
		}

		public function resume():void {
			queue.resume();
		}

		public function clear():void {
			queue.empty(true, true);
			queue.dispose(true);
			queue = new LoaderMax({
									  onComplete: onQueueCompleted,
									  onProgress: onQueueProgress,
									  onError: onQueueError
								  });
		}

		private function onQueueCompleted(event:LoaderEvent):void {
			onCompleted.dispatch();
		}

		private function onQueueProgress(event:LoaderEvent):void {
			onProgress.dispatch(event.target.progress);
		}

		private function onQueueError(event:LoaderEvent):void {
			onError.dispatch(event.target, event.text);
		}
	}
}
