package twinlist.filter
{
	import twinlist.ItemAttribute;
	import twinlist.ListItem;
	
	[Bindable]
	public class NumericalFilter implements IFilter
	{
		private var attrName:String;
		private var minValue:Number;
		private var maxValue:Number;

		public function NumericalFilter(attrName:String, minVal:Number = Number.NaN, maxVal:Number = Number.NaN)
		{
			Name = attrName;
			MinValue = minValue;
			MaxValue = maxValue;
		}
		
		public function get AttributeName():String
		{
			return attrName;
		}
		public function set AttributeName(attrName:String):void
		{
			this.attrName = attrName;
		}
		
		public function get MinValue():Number
		{
			return minValue;
		}
		public function set MinValue(value:Number):void
		{
			this.minValue = value;
		}
		
		public function get MaxValue():Number
		{
			return maxValue;
		}
		public function set MaxValue(value:Number):void
		{
			this.maxValue = maxValue;
		}
		
		public function Apply(item:ListItem):Boolean
		{
			if (isNaN(MinVal) && isNaN(MaxVal))
				return true;
			var attr:ItemAttribute = item.Attributes[AttributeName];
			if (attr.Type != ItemAttribute.TYPE_NUMERICAL)
				throw new Error("NumericalFilter only valid for ItemAttribute.TYPE_NUMERICAL.");
			if (attr == null || attr.Values == null)
				return false;
			for each (var val:Object in attr.Values) {
				if (!isNaN(MinVal) && val < MinValue)
					return false;
				if (!isNaN(MaxVal) && val > MaxValue)
					return false;
			}
			return true;
		}
	}
}