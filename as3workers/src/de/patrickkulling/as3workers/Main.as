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