/*
 * Copyright (c) 2012 Patrick Kulling
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
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