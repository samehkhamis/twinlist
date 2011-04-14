package twinlist.filter
{
	import twinlist.ListItem;
	import twinlist.ListItemAttribute;

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
			var attr:ListItemAttribute = item.Attributes[AttributeName];
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