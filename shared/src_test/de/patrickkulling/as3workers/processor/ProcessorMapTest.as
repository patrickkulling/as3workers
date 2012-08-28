package de.patrickkulling.as3workers.processor{	import org.flexunit.asserts.assertEquals;	import org.flexunit.asserts.assertNotNull;	import org.flexunit.asserts.assertTrue;	public class ProcessorMapTest	{		private var processorMap:ProcessorMap;		[Before]		public function before()		{			processorMap = new ProcessorMap();		}		[Test]		public function test_getProcessor_should_return_Empty_Processor_if_not_mapped():void		{			var processor:Processor = processorMap.getProcessor(0);			assertNotNull(processor);			assertTrue(processor is EmptyProcessor);		}		[Test]		public function test_map_should_create_mapping():void		{			var testProcessor:TestProcessor = new TestProcessor();			processorMap.map(0, testProcessor);			var processor:Processor = processorMap.getProcessor(0);			assertEquals(processor, testProcessor);		}		[Test]		public function test_map_should_override_previous_mapping():void		{			var testProcessor:TestProcessor = new TestProcessor();			processorMap.map(0, testProcessor);			processorMap.map(0, new TestProcessor());			var processor:Processor = processorMap.getProcessor(0);			assertTrue(processor != testProcessor);		}	}}import de.patrickkulling.as3workers.processor.Processor;import flash.utils.ByteArray;class TestProcessor implements Processor{	public function process(message:ByteArray):void	{	}}