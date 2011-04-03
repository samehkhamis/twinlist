package twinlist
{
	public class ListViewerItem
	{
		private var l1_unique:ListItem;
		private var l1_similar:ListItem;
		private var identical:ListItem;
		private var l2_similar:ListItem;
		private var l2_unique:ListItem;
		
		public function ListViewerItem()
		{
		}
		
		public function get L1Unique():ListItem
		{
			return l1_unique;
		}
		public function set L1Unique(item:ListItem):void
		{
			l1_unique = item;
		}
		
		public function get L1Similar():ListItem
		{
			return l1_similar;
		}
		public function set L1Similar(item:ListItem):void
		{
			l1_similar = item;
		}
		
		public function get Identical():ListItem
		{
			return identical;
		}
		public function set Identical(item:ListItem):void
		{
			identical = item;
		}
		
		public function get L2Similar():ListItem
		{
			return l2_similar;
		}
		public function set L2Similar(item:ListItem):void
		{
			l2_similar = item;
		}
		
		public function get L2Unique():ListItem
		{
			return l2_unique;
		}
		public function set L2Unique(item:ListItem):void
		{
			l2_unique = item;
		}
	}
}