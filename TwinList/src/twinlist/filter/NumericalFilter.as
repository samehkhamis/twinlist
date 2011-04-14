package twinlist.filter
{
	public class NumericalFilter implements IFilter
	{
		private var attrName:String;
		private var minValue:Number;
		private var maxValue:Number;

		public function NumericalFilter(attrName:String, minVal:Number = null, maxVal:Number = null)
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
			var attr:ListItemAttribute = item.Attributes[AttributeName];
			if (attr == null || attr.Values == null)
				return false;
			for each (var val:Object in attr.Values) {
				if (MinVal != null && val < MinValue)
					return false;
				if (MaxVal != null && val > MaxValue)
					return false;
			}
			return true;
		}
	}
}