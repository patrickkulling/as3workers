package de.patrickkulling.as3workers
{

	import de.patrickkulling.as3workers.message.MessageID;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	public class Main extends Sprite
	{
		[Embed(source="./../../../../../out/production/ExampleWorker/ExampleWorker.swf", mimeType="application/octet-stream")]
		public var ExampleWorkerClass:Class;

		private var exampleWorker:Worker;
		private var senderChannel:MessageChannel;
		private var receiverChannel:MessageChannel;

		public function Main()
		{
			initAndStartWorker();

			addMouseListeners();
		}

		private function initAndStartWorker():void
		{
			createWorker();
			createMessageChannels();
			attachMessageChannelsToWorker();

			exampleWorker.start();
		}

		private function createWorker():void
		{
			exampleWorker = WorkerDomain.current.createWorker(new ExampleWorkerClass());
		}

		private function createMessageChannels():void
		{
			senderChannel = Worker.current.createMessageChannel(exampleWorker);
			receiverChannel = exampleWorker.createMessageChannel(Worker.current);
		}

		private function attachMessageChannelsToWorker():void
		{
			exampleWorker.setSharedProperty("de.patrickkulling.as3worker.receiverChannel", senderChannel);
			exampleWorker.setSharedProperty("de.patrickkulling.as3worker.senderChannel", receiverChannel);
		}

		private function addMouseListeners():void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
			stage.addEventListener(MouseEvent.CLICK, handleClick);

			var timer:Timer = new Timer(2000);
			timer.addEventListener(TimerEvent.TIMER, handleTimer);
			timer.start();
		}

		private function handleTimer(event:TimerEvent):void
		{
			var message:ByteArray = new ByteArray();
			message.writeInt(MessageID.SEND_PING);
			message.writeUTF("ping");

			senderChannel.send(message);
		}

		private function handleMouseMove(event:MouseEvent):void
		{
			var message:ByteArray = new ByteArray();
			message.writeInt(MessageID.MOUSE_MOVE);
			message.writeDouble(event.stageX);
			message.writeDouble(event.stageY);

			senderChannel.send(message);
		}

		private function handleClick(event:MouseEvent):void
		{
			var message:ByteArray = new ByteArray();
			message.writeInt(MessageID.MOUSE_CLICK);
			message.writeUTF("clicked");

			senderChannel.send(message);
		}
	}
}