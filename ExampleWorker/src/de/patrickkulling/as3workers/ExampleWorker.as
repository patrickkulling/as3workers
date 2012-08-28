package de.patrickkulling.as3workers
{

	import de.patrickkulling.as3workers.processor.MouseClickProcessor;
	import de.patrickkulling.as3workers.processor.MouseMoveProcessor;
	import de.patrickkulling.as3workers.processor.ProcessorMap;
	import de.patrickkulling.as3workers.processor.Processor;
	import de.patrickkulling.as3workers.processor.ReceivePingProcessor;
	import de.patrickkulling.as3workers.message.MessageID;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.ByteArray;

	public class ExampleWorker extends Sprite
	{
		private var receiverChannel:MessageChannel;
		private var processorMap:ProcessorMap;

		public function ExampleWorker()
		{
			getMessageChannels();
			mapCommands();
			addMessageChannelListener();
		}

		private function getMessageChannels():void
		{
			receiverChannel = Worker.current.getSharedProperty("de.patrickkulling.as3worker.receiverChannel");
		}

		private function mapCommands():void
		{
			processorMap = new ProcessorMap();
			processorMap.map(MessageID.MOUSE_MOVE, new MouseMoveProcessor());
			processorMap.map(MessageID.MOUSE_CLICK, new MouseClickProcessor());
			processorMap.map(MessageID.SEND_PING, new ReceivePingProcessor());
		}

		private function addMessageChannelListener():void
		{
			if (receiverChannel != null)
				receiverChannel.addEventListener(Event.CHANNEL_MESSAGE, handleChannelMessage);
		}

		private function handleChannelMessage(event:Event):void
		{
			var message:ByteArray = receiverChannel.receive();
			var id:int = message.readInt();

			var processor:Processor = processorMap.getProcessor(id);
			processor.process(message);
		}
	}
}