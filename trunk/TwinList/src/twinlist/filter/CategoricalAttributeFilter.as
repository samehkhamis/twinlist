package twinlist.filter
{
	import twinlist.ItemAttribute;
	import twinlist.ListItem;

	[Bindable]
	public class CategoricalAttributeFilter implements IFilter
	{
		private var attrName:String;
		private var values:Array;
		
		public function CategoricalAttributeFilter(attrName:String, values:Array = null)
		{
			AttributeName = attrName;
			Values = new Array();
			if (values != null)
				Values.push(values);
			this.values.push(values);
		}
		
		public function get AttributeName():String
		{
			return attrName;
		}
		public function set AttributeName(attrName:String):void
		{
			this.attrName = attrName;
		}
		
		public function get Values():Array
		{
			return values;
		}
		public function set Values(values:Array):void
		{
			this.values = values;
		}
		
		public function Apply(item:ListItem):Boolean
		{
			if (Values == null || Values.length == 0)
				return true;
			if (AttributeName == "Name") {
				for each (var name:String in Values) {
					if (item.Name == name)
						return true;
				}
			}
			var attr:ItemAttribute = item.Attributes[AttributeName];
			if (attr == null || attr.Values == null)
				return false;
			for each (var val:Object in Values) {
				if (attr.Values.indexOf(val) != -1)
					return true;
			}
			return false;
		}
	}
}