package com.d5power.utils
{
	public class CharEffectImplement
	{
		/**
		 * 效果名
		 */ 
		public var name:String='';
		/**
		 * 对应动作
		 */ 
		public var actionRes:String;
		/**
		 * 播放起始帧
		 */ 
		public var startFrame:uint;
		/**
		 * 主素材资源
		 */ 
		public var res:String;
		/**
		 * 不同方向的坐标配置
		 */ 
		private var _directionPos:Array;
		/**
		 * 不同方向的素材方向映射关系
		 */ 
		private var _directionMaps:Array;
		
		/**
		 * 播放速度
		 */ 
		public var playSpeed:uint;
		/**
		 * 移动角度
		 */ 
		private var _moveAngleMaps:Array;
		
		/**
		 * 移动速度
		 */  
		public var moveSpeed:Number=0;
		
		/**
		 * 最大飞行距离
		 */ 
		public var moveDistance:uint;
		
		/**
		 * 旋转角度
		 */ 
		private var _rotationMaps:Array;
		
		/**
		 * 旋转速度
		 */ 
		public var rotationSpeed:Number=0;
		
		/**
		 * 自动生成子对象速度，可借此与角度计算出子对象的生成位置
		 */ 
		public var sonSpeed:uint;
		/**
		 * 自动生成子对象的帧
		 */ 
		public var sonFrame:uint;
		/**
		 * 自动生成子对象的深度（即生成多少次后停止生成）
		 */ 
		public var sonFrameDeep:uint;
		/**
		 * 不同方向的子对象旋转角度映射
		 */ 
		private var _sonAngleMaps:Array;
		/**
		 * 运动模式 0-默认 1-向目标运行
		 */ 
		public var actionMode:uint;
		
		/**
		 * 运行模式 0-循环 1-单次
		 */ 
		public var runMode:uint;
		
		/**
		 * 缩放比
		 */ 
		public var zoom:Number=1;
		
		/**
		 * 混合模式开关
		 */ 
		public var blendSwitch:uint=0;
		
		/**
		 * 子对象散射角度 - 本参数不提供给游戏对象使用，而是供生成时候进行判断
		 */ 
		public var sonAngleAdd:uint = 0;
		
		/**
		 * 子对象散射个数 - 本参数不提供给游戏对象使用，而是供生成时候进行判断,如为0，应根据散射角度自动计算
		 */ 
		public var sonAngleAddNum:uint = 0;
		
		/**
		 * 是否在最下层
		 */ 
		public var lowLv:uint=0;
		
		public var index:uint;
		
		
		public function CharEffectImplement()
		{
			_directionMaps = new Array();
			_directionPos = new Array();
			_sonAngleMaps = new Array();
			_rotationMaps = new Array();
			_moveAngleMaps = new Array();
		}
		
		/**
		 * 获取某个方向的子对象生成角度
		 */ 
		public function getSonAngle(dir:uint):Number
		{
			if(_sonAngleMaps[dir]==null) return 0;
			return _sonAngleMaps[dir];
		}
		/**
		 * 获取某个方向的旋转角度
		 */
		public function getRotation(dir:uint):Number
		{
			if(_rotationMaps[dir]==null) return 0;
			return _rotationMaps[dir];
		}
		/**
		 * 获取某个方向的移动角度
		 */
		public function getMoveAngle(dir:uint):Number
		{
			if(_moveAngleMaps[dir]==null) return 0;
			return _moveAngleMaps[dir];
		}
		/**
		 * 获取某个方向的位移
		 */
		public function getDirectionPos(dir:uint):Array
		{
			if(_directionPos[dir]==null) return [0,0];
			return _directionPos[dir];
		}
		
		public function format(xml:Object):void
		{
			name = xml.@name;
			actionRes = xml.@actionRes;
			startFrame = xml.@startFrame;
			res = xml.@res;
			playSpeed = xml.@playSpeed;
			rotationSpeed = xml.@rotationSpeed;
			sonSpeed = xml.@sonSpeed;
			sonFrame = xml.@sonFrame;
			sonFrameDeep = xml.@sonFrameDeep;
			runMode = xml.@runMode;
			actionMode = xml.@actionMode;
			moveSpeed = xml.@moveSpeed;
			moveDistance = xml.@moveDistance;
			zoom = xml.@zoom;
			blendSwitch = xml.@blendSwitch;
			sonAngleAdd = xml.@sonAngleAdd;
			lowLv = xml.@lowLv;
			sonAngleAddNum = xml.@sonAngleAddNum;
			index = int(xml.@index);

			for each(var dir:Object in xml.directionMap)
			{
				_directionPos[int(dir.@direction)] = [int(dir.@offsetX),int(dir.@offsetY)];
				_directionMaps[int(dir.@direction)] = int(dir.@directionMap);
				_sonAngleMaps[int(dir.@direction)] = Number(dir.@angleMap);
				_rotationMaps[int(dir.@direction)] = Number(dir.@rotationMap);
				_moveAngleMaps[int(dir.@direction)] = Number(dir.@moveAngle);
			}
		}
	}
}