package twinlist.xml
{
	import com.carlcalderon.arthropod.Debug;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	
	import twinlist.ListViewerItem;
	import twinlist.SimilarityItem;
	import twinlist.list.ItemAttribute;
	import twinlist.list.List;
	import twinlist.list.ListItem;

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
			var simHash:Object=new Object();

			// Will load each similarity pair
			for each (var pair:XML in xml.children()) {
				
				var l1Index:String=pair.elements("L1Index");
				var l2Index:String=pair.elements("L2Index");
				var type:uint=uint(pair.elements("Type"));
				var diffs:uint=uint(pair.elements("Diffs"));
				
				var diffList:ArrayCollection=null;
				if (diffs > 0) {

					diffList=new ArrayCollection();
					
					for each (var diff:XML in pair.elements("Difference").children()) {

						// Attribute difference and portions of the strings that should be highlighted
						var name:String=diff.elements("Name");
						var l1Diff:String=diff.elements("L1Diff");
						var l2Diff:String=diff.elements("L2Diff");
						
						var diffItem:DifferenceItem = new DifferenceItem(name, l1Diff, l2Diff);

						diffList.addItem(diffItem);
					}
					
				}
					
				var item:SimilarityItem=new SimilarityItem(l1Index,l2Index,type,diffs,diffList);
				var key: String;
				if (l1Index == "")
					key=l2Index;
				else if (l2Index == "")
					key=l1Index;
				else key=l1Index+l2Index;
				
				simHash[key]=item;
	
			}
			callback.call(null, simHash);
		}
	
	
	}
}