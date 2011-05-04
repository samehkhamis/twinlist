package twinlist.filter
{
	import twinlist.list.ListItem;
	import twinlist.list.ItemAttribute;
	
	[Bindable]
	public class GeneralAttributeFilter implements IFilter
	{
		private var attrName:String;
		private var filterString:String

		public function GeneralAttributeFilter(attrName:String, filterString:String = null)
		{
			AttributeName = attrName;
			FilterString = filterString;
		}
		
		public function get AttributeName():String
		{
			return attrName;
		}
		public function set AttributeName(attrName:String):void
		{
			this.attrName = attrName;
		}
		
		public function get FilterString():String
		{
			return filterString;
		}
		public function set FilterString(filterString:String):void
		{
			this.filterString = filterString;
		}
		
		public function Apply(item:ListItem):Boolean
		{
			if (filterString == null || filterString == "")
				return true;
			if (AttributeName == "Name")
				return item.Name == filterString;
			var attr:ItemAttribute = item.Attributes[AttributeName];
			if (attr == null || attr.Values == null)
				return false;
			for each (var val:Object in attr.Values) {
				if (val == filterString)
					return true;
			}
			return false;
		}
	}
}