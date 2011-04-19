package twinlist.xml
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	
	import twinlist.list.SimilarityItem;

	public class XmlSimilarityLoader
	{
		public function XmlSimilarityLoader(fileName:String, callback:Function)
		{
			var urlReq:URLRequest = new URLRequest(fileName);
			var loader:URLLoader = new URLLoader(urlReq);
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, function(event:Event):void {
				ReadXml(loader, callback);
			});
		}
		
		private function ReadXml(loader:URLLoader, callback:Function):void {
		
			var xml:XML = XML(loader.data);
			var simHash:Object = new Object();

			// Will load each similarity pair
			for each (var pair:XML in xml.children()) {
				var l1Id:String = pair.elements("L1ID");
				var l2Id:String = pair.elements("L2ID");
				var type:uint = uint(pair.elements("Type"));
				var diffs:uint = uint(pair.elements("Diffs"));
				var diffList:Array = null;
				
				if (diffs > 0) {
					diffList = new Array(diffs);
					var idx:int = 0;
					for each (var diff:XML in pair.elements("Difference").children()) {
						// Attribute difference and portions of the strings that should be highlighted
						var name:String = diff.elements("Name");
						var l1Diff:String = diff.elements("L1Diff");
						var l2Diff:String = diff.elements("L2Diff");
						var diffItem:DifferenceItem = new DifferenceItem(name, l1Diff, l2Diff);
						diffList[idx++] = diffItem;
					}
				}
				var item:SimilarityItem = new SimilarityItem(l1Id, l2Id, type, diffList);
				simHash[l1Id + ":" + l2Id] = item;
			}
			callback.call(null, simHash);
		}
	}
}