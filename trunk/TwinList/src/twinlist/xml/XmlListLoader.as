package twinlist.xml
{
	import com.carlcalderon.arthropod.Debug;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import twinlist.list.ItemAttribute;
	import twinlist.list.List;
	import twinlist.list.ListItem;
	
	public class XmlListLoader
	{
		public function XmlListLoader(fileName:String, callback:Function)
		{
			var urlReq:URLRequest = new URLRequest(fileName);
			var loader:URLLoader = new URLLoader(urlReq);
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, function(event:Event):void {
				ReadXml(loader, callback);
			});
		}
		
		private function ReadXml(loader:URLLoader, callback:Function):void
		{
			
			var xml:XML = XML(loader.data);
			var listId:String = xml.attribute("id");
			var listName:String = xml.attribute("name");
			var list:List = new List(listId, listName);
			for each (var itemXml:XML in xml.children()) {
				var itemId:String = itemXml.attribute("id");
				var itemName:String = itemXml.attribute("name");
				var item:ListItem = new ListItem(itemId, itemName);
				for each (var attrXml:XML in itemXml.children()) {
					var attrName:String = attrXml.attribute("name");
					var attr:ItemAttribute = new ItemAttribute(attrName);
					switch (attrXml.attribute("type").toString()) {
						case "Categorical":
							attr.Type = ItemAttribute.TYPE_CATEGORICAL;
							break;
						case "Numerical":
							attr.Type = ItemAttribute.TYPE_NUMERICAL;
							attr.Unit = attrXml.attribute("unit").toString();
							break;
						default:
							attr.Type = ItemAttribute.TYPE_GENERAL;
							break;
					}
					attr.Values = new Array();
					for each (var valXml:XML in attrXml.children()) {
						var value:Object;
						if (attr.Type == ItemAttribute.TYPE_NUMERICAL)
							value = parseFloat(valXml.attribute("value").toString());
						else
							value = valXml.attribute("value").toString();
						attr.Values.push(value);
					}
					item.Attributes[attr.Name] = attr;
				}
				list.addItem(item);
			}
			callback.call(null, list);
		}
	}
}