package com.d5power.core
{
	import com.d5power.utils.ItemData;
	import com.d5power.utils.MonsterData;
	import com.d5power.utils.NpcData;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class D5ConfigCenter
	{
		public static const COMMON:uint = 0;
		public static const EDITOR:uint = 1;
		private var _WORK_MODE:uint = 0;
		/**
		 * 已用NPC列表
		 */ 
		protected const PATH_NPC_LIST:String = 'asset/data/npclist.d5conf';
		
		/**
		 * 道具数据
		 */ 
		protected const PATH_ITEM_CONFIG:String = 'asset/data/item_data.xml';
		/**
		 * 怪物数据
		 */ 
		protected const PATH_MONSTER_CONFIG:String = 'asset/data/monster_data.xml';
		
		/**
		 * 条件索引
		 */ 
		protected const PATH_TYPE:String = 'asset/data/type.xml';
		
		/**
		 * 游戏道具列表
		 */ 
		protected var item_config:Array;
		
		/**
		 * 游戏怪物列表
		 */ 
		protected var monster_config:Array;
		
		/**
		 * NPC列表（放入场景中的NPC）
		 */ 
		protected var npc_list:Dictionary;
		
		private static var _me:D5ConfigCenter;
		
		public static function get me():D5ConfigCenter
		{
			if(_me==null) _me = new D5ConfigCenter(COMMON);
			
			return _me;
		}

		public function D5ConfigCenter(mode:uint)
		{
			_WORK_MODE = mode;
		}
		
		private var _step:uint;
		public function init():void
		{
			_step++;
			switch(_step)
			{
				case 1:
					setupItemConfig();
					break;
				case 2:
					setupMonsterConfig();
					break;
				case 3:
					setupNpcConfig();
					break;
				default:
					trace("配置中心初始化完成");
					break;
			}
		}
		
		public function getItem(id:uint):ItemData
		{
			D5ConfigCenter.me.setupItemConfig();
			
			for each(var obj:ItemData in item_config)
			{
				if(obj.id==id) return obj;
			}
			return null;
		}
		
		
		public function getMonster(id:uint):MonsterData
		{
			for each(var obj:MonsterData in monster_config)
			{
				if(obj.id==id) return obj;
			}
			return null;
		}
		
		public function getMonsterDataById(id:uint):MonsterData
		{
			for each(var data:MonsterData in monster_config)
			{
				if(data.id==id) return data;
			}
			
			return null;
		}
		
		/**
		 * 增加新的道具
		 */ 
		public function addItemConfig(data:ItemData):void
		{
			item_config.push(data);
		}
		/**
		 * 增加新的怪物
		 */ 
		public function addMonsterConfig(data:MonsterData):void
		{
			monster_config.push(data);
		}
		
		public function getNpcData(id:uint):NpcData
		{
			setupNpcConfig();
			return npc_list[id];
		}
		
		public function setupNpcConfig():void
		{
			if(npc_list==null)
			{
				var parse:Function = function(v:ByteArray):void
				{
					npc_list = new Dictionary();
					if(v!=null)
					{
						v.position = 0;
						
						var num:uint = v.readUnsignedShort();
						var obj:NpcData;
						for(var i:uint = 0;i<num;i++)
						{
							obj = new NpcData();
							obj.load(v);
							if(obj.id>0)
							{
								npc_list[obj.id] = obj;
							}
						}
					}
					
					if(_step>0) init();
				};
				
				loadConfig(PATH_NPC_LIST,parse);
			}
		}
		
		public function setupMonsterConfig():void
		{
			if(monster_config==null)
			{
				var parse:Function = function(v:ByteArray):void
				{
					monster_config = new Array();
					if(v!=null)
					{
						v.position = 0;
						
						var data:XML = new XML(v.readUTFBytes(v.bytesAvailable));
						
						var field:Object;
						for each(var obj:Object in data.monster)
						{
							if(field==null) field = obj.@*;
							var monsterdata:MonsterData = new MonsterData();
							for each(var k:Object in field)
							{
								monsterdata[String(k.name())] = obj["@"+k.name()];
							}
							addMonsterConfig(monsterdata);
						}
					}
					if(_step>0) init();
				}
				
				if(!loadConfig(PATH_MONSTER_CONFIG,parse,false)) monster_config = new Array();
			}
		}
		
		/**
		 * 加载项目已存在的道具配置文件
		 */ 
		public function setupItemConfig():void
		{
			if(item_config==null)
			{
				var parse:Function = function(v:ByteArray):void
				{
					
					item_config = new Array();
					if(v!=null)
					{
						v.position = 0;
						var data:XML = new XML(v.readUTFBytes(v.bytesAvailable));
						var field:Object;
						
						for each(var obj:Object in data.item)
						{
							if(field==null) field = obj.@*;
							var itemdata:ItemData = new ItemData();
							for each(var k:Object in field)
							{
								itemdata[String(k.name())] = obj["@"+k.name()];
							}
							addItemConfig(itemdata);
						}
					}
					if(_step>0) init();
				}
				
				loadConfig(PATH_ITEM_CONFIG,parse,false);
			}
		}
		
		
		public function loadConfig(path:String,parse:Function,isEditor:Boolean=true):Boolean
		{
			var onLoaded:Function = function(e:Event):void
			{
				urlloader.removeEventListener(Event.COMPLETE,onLoaded);
				urlloader.removeEventListener(IOErrorEvent.IO_ERROR,onLoadError);
				parse(urlloader.data);
			};
			
			var onLoadError:Function = function(e:IOErrorEvent):void
			{
				urlloader.removeEventListener(Event.COMPLETE,onLoaded);
				urlloader.removeEventListener(IOErrorEvent.IO_ERROR,onLoadError);
				parse(null);
			}
			
			var urlloader:URLLoader = new URLLoader();
			urlloader.dataFormat = URLLoaderDataFormat.BINARY;
			urlloader.addEventListener(Event.COMPLETE,onLoaded);
			urlloader.addEventListener(IOErrorEvent.IO_ERROR,onLoadError);
			urlloader.load(new URLRequest(path));
			
			return true;
		}
		
		protected function getRoot(isEditor:Boolean=true):String
		{
			return '';
		}
		
	}
}