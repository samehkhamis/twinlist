package twinlist.xml
{
	public class DifferenceItem
	{
		private var name:String;
		private var l1Diff:String;
		private var l2Diff:String;
		
		public function DifferenceItem(name:String, l1Diff:String, l2Diff:String) {
		
			this.name=name;
			this.l1Diff=l1Diff;
			this.l2Diff=l2Diff;
		}
		
		public function get Name(): String {
			return name;
		}
		
		public function get L1Diff(): String {
			return l1Diff;
		}
		
		public function get L2Diff(): String {
			return l2Diff;
		}
	}
}