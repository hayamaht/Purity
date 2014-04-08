package cc.hayama.purity.services {

	import cc.hayama.IDisposable;
	import org.osflash.signals.Signal;

	public interface IService extends IDisposable {
		function get onCompleted():Signal;
		function get onError():Signal;

		function init():void;

		function send(... args):void;
	}
}
