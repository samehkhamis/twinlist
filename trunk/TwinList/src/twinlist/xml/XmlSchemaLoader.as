package twinlist.xml
{
	import com.carlcalderon.arthropod.Debug;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	import twinlist.list.ItemAttribute;
	import twinlist.list.AttributeDescriptor;
	import twinlist.list.List;
	import twinlist.list.ListItem;
	import twinlist.list.ListSchema;
	
	public class XmlSchemaLoader
	{
		public function XmlSchemaLoader(fileName:String, callback:Function)
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
			var schema:ListSchema = new ListSchema();
			for each (var attrXml:XML in xml.children()) {
				var attrName:String = attrXml.attribute("name");
				var attrDesc:AttributeDescriptor = new AttributeDescriptor(attrName);
				var typeStr:String = attrXml.child("type")[0].toXMLString();
				attrDesc.Type=attrDesc.getAttributeType(typeStr);
				if(attrXml.child("unit") != null){
				  attrDesc.Properties[AttributeDescriptor.PROP_UNIT]= attrXml.child("unit")[0].toXMLString();
				}
				schema.addAttribute(attrName,attrDesc);
			 }
			
			callback.call(null, schema);
		}
	}
}